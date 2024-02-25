#!/bin/bash

# Bootstrap script configuration defaults
LOG_FILE="/var/log/raemis_bootstrap.log"
DONGLE_PATH="/etc/raemis/Unlocked_2038Expiry.xml"
CONFIG_FILE_PATH="/etc/raemis/raemis_bootstrap_config.env"

# Landing Site Configuration defaults
#RAN_CP="gre0"
#RAN_DP="gre0"
#WAN="ens256"
#MCC="315"
#MNC="010"
ROUTING_MODE="OS"
NETWORK_MGMT_READ_ONLY="False"
DB_INTEG_LVL=1

# Raemis NMS Client configuration defautls
WEB_TOKEN_SECRET_ALGORITHM="HS256"
NMS_CLIENT_RECONNECT_TIME="30"
NMS_CA_CERT_PATH="/etc/raemis/nms_keys/ca/ca_cert.pem"
NMS_CERT_PATH="/etc/raemis/nms_keys/client/client_cert.pem"
NMS_KEY_PATH="/etc/raemis/nms_keys/client/private/client_key.pem"

SOLUTION_TYPE="pcn"

# UPF configuration
SMF_API_PORT=443
IPV4_POOL="10.254.0.2-10.254.255.254"
PRIMARY_DNS="8.8.8.8"
SECONDARY_DNS="8.8.4.4"
SMF_N4_PORT=8013

function print_usage 
{
    echo -e "Environment variable based configuration file located at /etc/raemis/raemis_bootstrap_config.env\n"
    echo -e "Log file from this script output to /var/log/raemis_bootstrap.log\n"
    echo -e "Usage:\n"
    echo -e "$0 [OPTIONS]...\n"
    echo "-t SOLUTION_TYPE : The Raemis Solution Type e.g. pcn, upf"
    echo -e "-h : Print usage\n"
    echo ""
    exit 0
}

echo "Starting bootstrap script" | tee -a ${LOG_FILE}

# Get script arguments
while getopts t:h flag
do
    case "${flag}" in
        t) SOLUTION_TYPE=${OPTARG} ;;
        h) print_usage ;;
        *) print_usage ;; 
    esac
done

if [ $# -eq 0 ]; then
    print_usage
fi

if [ ! -f "$CONFIG_FILE_PATH" ]; then
    echo "ERROR - Config file path does not point to file - ${CONFIG_FILE_PATH}" | tee -a ${LOG_FILE}
    exit 1
fi

# Source the env config varaibles from the specified file
source ${CONFIG_FILE_PATH}

# If Raemis is already running, reset Raemis to factory defaults before running bootstrap script
# Has been commented out for 5.2.5.0-1 as factory.db does not contain all objects needed.
#rsp_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 --interface 127.0.0.2 -X GET "http://127.0.0.1/api/raemis"); 
#if [[ "$rsp_code" = 200 ]]; then
#    echo "Resetting Raemis to factory defaults before running bootstrap" | tee -a ${LOG_FILE}
#    raemis_id=$(curl -s --interface 127.0.0.2 -X GET "http://127.0.0.1/api/raemis" | jq -r '.[0].id')
#    curl -s -o /dev/null --max-time 5 --interface 127.0.0.2 -X PATCH http://127.0.0.1/api/raemis?id=${raemis_id} -d 'admin_state=4' | tee -a ${LOG_FILE};
#
#    sleep 5
#
#    # Wait for Raemis to come up after factory reset
#    rsp_code="0";
#    while [[ "$rsp_code" != 200 ]]; do
#        rsp_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 --interface 127.0.0.2 -X GET "http://127.0.0.1/api/raemis"); 
#        sleep 1;
#    done;
#fi

# 5.2.5.0-1 + installs script already installs a unlocked dongle
#if [ ! -z "$DONGLE_PATH" ]; then
#    if [ ! -f "$DONGLE_PATH" ]; then
#        echo "ERROR - DONGLE_PATH path does not point to file - ${DONGLE_PATH}" | tee -a ${LOG_FILE}
#        exit 1
#    fi
#
#    # Apply the dongle
#    echo "Installing dongle from path - ${DONGLE_PATH}" | tee -a ${LOG_FILE}
#    raemis_install_virtual_dongle -x ${DONGLE_PATH}
#    ret=$?
#
#    # 0   = 'HASP_STATUS_OK;Request successfully completed'
#    # 65  = 'HASP_UPDATE_ALREADY_ADDED;Specified V2C update already installed in the LLM'
#    if [ $ret -eq 0 ]; then
#        echo "Successfully applied dongle" | tee -a ${LOG_FILE}
#        # Restart raemis service now that dongle has been applied
#        systemctl restart raemis
#    elif [ $ret -eq 65 ]; then
#        echo "Dongle was already installed" | tee -a ${LOG_FILE}
#    else
#        echo "Failed to install dongle - return code - ${ret}" | tee -a ${LOG_FILE}
#        exit 1
#    fi
#fi

# Push basic configuration via landing site
curl -k -s -o /dev/null --max-time 15 -F "ran=${RAN_CP}" -F "s1u=${RAN_DP}" -F "wan=${WAN}" -F "onm=${WAN}" -F "userEntry_mcc=${MCC}" -F "userEntry_mnc=${MNC}" -F "db_integrity_level=${DB_INTEG_LVL}" -F "net_mgmt_app_mode=${NETWORK_MGMT_READ_ONLY}" -F "user_traffic_routing_mode=${ROUTING_MODE}" -F 'MCC_MNC_Submit_Button=Submit' 'http://127.0.0.1:8088'

# Ensure Raemis is running
echo "Waiting for Raemis GUI & API to start ..." | tee -a ${LOG_FILE}
# Wait for Raemis to come up and API to start
rsp_code="0";
while [[ "$rsp_code" != 200 ]]; do
    rsp_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 --interface 127.0.0.2 -X GET "http://127.0.0.1/api/raemis"); 
    sleep 1;
done;
echo "Raemis GUI & API ready" | tee -a ${LOG_FILE}

# Create eula_acceptance for raemis api_user
if [ $(curl --interface 127.0.0.2 http://127.0.0.1/api/count/eula_acceptance?api_user=raemis | jq -r '.[0]') -eq 0 ]; then
    echo "Creating eula_acceptance for raemis api_user" | tee -a ${LOG_FILE}
    rsp_code=$(curl -o /dev/null -w "%{http_code}" --interface 127.0.0.2 -X POST "http://127.0.0.1/api/eula_acceptance" -d "api_user=raemis")
    if [[ "$rsp_code" != 200 ]]
    then
        echo "Failed to create eula_acceptance for raemis api_user - response code - $rsp_code"
        exit 1
    fi
fi

# Create web_token_secret
if [ $(curl --interface 127.0.0.2 http://127.0.0.1/api/count/web_token_secret?name=${WEB_TOKEN_IDENTITY} | jq -r '.[0]') -eq 0 ]; then
    echo "Creating web_token_secret" | tee -a ${LOG_FILE}
    rsp_code=$(curl -o /dev/null -w "%{http_code}" --interface 127.0.0.2 -X POST "http://127.0.0.1/api/web_token_secret" -d "name=${WEB_TOKEN_IDENTITY}" -d "identity=${WEB_TOKEN_IDENTITY}" -d "algorithm=${WEB_TOKEN_SECRET_ALGORITHM}" -d "secret=${NMS_IDENTITY}")
    if [[ "$rsp_code" != 200 ]]
    then
        echo "Failed to create web_token_secret - response code - $rsp_code"
        exit 1
    fi
fi

# Create nms_file objects
file_basename=$(basename ${NMS_CA_CERT_PATH})
if [ $(curl --interface 127.0.0.2 http://127.0.0.1/api/count/nms_file?filename=${file_basename} | jq -r '.[0]') -eq 0 ]; then
    echo "Creating nms_file for ${NMS_CA_CERT_PATH}" | tee -a ${LOG_FILE}

    # Ensure paths provided in config point to files
    if [ ! -f "$NMS_CA_CERT_PATH" ]; then
        echo "ERROR - NMS_CA_CERT_PATH does not point to file - ${NMS_CA_CERT_PATH}" | tee -a ${LOG_FILE}
        exit 1
    fi
    rsp_code=$(curl -o /dev/null -w "%{http_code}" --interface 127.0.0.2 -X POST "http://127.0.0.1/api/nms_file" -d "filename=${file_basename}" -d "data=$(hexdump -ve '1/1 "%02x"' ${NMS_CA_CERT_PATH})")
    if [[ "$rsp_code" != 200 ]]
    then
        echo "Failed to create nms_file ${NMS_CA_CERT_PATH} - response code - $rsp_code"
        exit 1
    fi
fi

# Get nms_file object id
nms_ca_cert_file_id=$(curl --interface 127.0.0.2 http://127.0.0.1/api/nms_file?filename=${file_basename} | jq -r '.[0].id')

file_basename=$(basename ${NMS_CERT_PATH})
if [ $(curl --interface 127.0.0.2 http://127.0.0.1/api/count/nms_file?filename=${file_basename} | jq -r '.[0]') -eq 0 ]; then
    echo "Creating nms_file for ${NMS_CERT_PATH}" | tee -a ${LOG_FILE}

    # Ensure paths provided in config point to files
    if [ ! -f "$NMS_CERT_PATH" ]; then
        echo "ERROR - NMS_CERT_PATH does not point to file - ${NMS_CERT_PATH}" | tee -a ${LOG_FILE}
        exit 1
    fi
    rsp_code=$(curl -o /dev/null -w "%{http_code}" --interface 127.0.0.2 -X POST "http://127.0.0.1/api/nms_file" -d "filename=${file_basename}" -d "data=$(hexdump -ve '1/1 "%02x"' ${NMS_CERT_PATH})")
    if [[ "$rsp_code" != 200 ]]
    then
        echo "Failed to create nms_file ${NMS_CERT_PATH} - response code - $rsp_code"
        exit 1
    fi
fi

# Get nms_file object id
nms_cert_file_id=$(curl --interface 127.0.0.2 http://127.0.0.1/api/nms_file?filename=${file_basename} | jq -r '.[0].id')

file_basename=$(basename ${NMS_KEY_PATH})
if [ $(curl --interface 127.0.0.2 http://127.0.0.1/api/count/nms_file?filename=${file_basename} | jq -r '.[0]') -eq 0 ]; then
    echo "Creating nms_file for ${NMS_KEY_PATH}" | tee -a ${LOG_FILE}

    # Ensure paths provided in config point to files
    if [ ! -f "$NMS_KEY_PATH" ]; then
        echo "ERROR - NMS_KEY_PATH does not point to file - ${NMS_KEY_PATH}" | tee -a ${LOG_FILE}
        exit 1
    fi
    rsp_code=$(curl -o /dev/null -w "%{http_code}" --interface 127.0.0.2 -X POST "http://127.0.0.1/api/nms_file" -d "filename=${file_basename}" -d "data=$(hexdump -ve '1/1 "%02x"' ${NMS_KEY_PATH})")
    if [[ "$rsp_code" != 200 ]]
    then
        echo "Failed to create nms_file ${NMS_KEY_PATH} - response code - $rsp_code"
        exit 1
    fi
fi

# Get nms_file object id
nms_key_file_id=$(curl --interface 127.0.0.2 http://127.0.0.1/api/nms_file?filename=${file_basename} | jq -r '.[0].id')

# Create nms_client
if [ $(curl --interface 127.0.0.2 http://127.0.0.1/api/count/nms_client?nms_hostname=${NMS_IP} | jq -r '.[0]') -eq 0 ]; then
    echo "Creating nms_client" | tee -a ${LOG_FILE}

    rsp_code=$(curl -o /dev/null -w "%{http_code}" --interface 127.0.0.2 -X POST "http://127.0.0.1/api/nms_client" -d "nms_hostname=${NMS_IP}" -d "nms_auth=${NMS_IDENTITY}" -d "reconnect_time=${NMS_CLIENT_RECONNECT_TIME}" -d "ssl_ca_cert_id=${nms_ca_cert_file_id}" -d "ssl_cert_id=${nms_cert_file_id}" -d "ssl_key_id=${nms_key_file_id}" -d "nms_identity=${NMS_IDENTITY}")
    if [[ "$rsp_code" != 200 ]]
    then
        echo "Failed to create nms_client - response code - $rsp_code"
        exit 1
    fi
fi

if [ ! -z "${N4}" ]
then
    echo "Setting N4 net_device for SMF" | tee -a ${LOG_FILE}
    rsp_code=$(curl -o /dev/null -w "%{http_code}" --interface 127.0.0.2 -X PATCH "http://127.0.0.1/api/mgw_ctrl?id=1" -d "net_device=lo,${N4}")
    if [[ "$rsp_code" != 200 ]]
    then
        echo "Failed to set N4 net_device for SMF - response code - $rsp_code"
        exit 1
    fi
fi

# Update media_gateway object so VoLTE/VoNR works with OCI networking
echo "Updating media_gateway so lower_net_device=tun_ims and upper_net_device=lo" | tee -a ${LOG_FILE}
rsp_code=$(curl -o /dev/null -w "%{http_code}" --interface 127.0.0.2 -X PATCH "http://127.0.0.1/api/media_gateway?id=1" -d "lower_netdevice=tun_ims" -d "upper_net_device=lo")
if [[ "$rsp_code" != 200 ]]
then
    echo "Failed to update media_gateway lower_net_device and upper_net_device - response code - $rsp_code"
    exit 1
fi

# Perform additional configuration required to configure instances as external UPF
if [ "$SOLUTION_TYPE" = "upf" ]
then
    echo "Attempting to configure SOLUTION_TYPE ${SOLUTION_TYPE}" | tee -a ${LOG_FILE}
    if [ -z "$SMF_IP" ] || [ -z "$SMF_API_USERNAME" ] || [ -z "$SMF_API_PASSWORD" ] || [ -z "$UPF_SELECTION_DNN" ]; 
    then
        echo "ERROR - Missing env required for UPF configuration - requires SMF_IP, SMF_API_USERNAME, SMF_API_PASSWORD, UPF_SELECTION_DNN to be set" | tee -a ${LOG_FILE}
        exit 1
    fi

    # Stop local raemis service so we can perform sqlite3 commands directly
    systemctl stop raemis

    # Ensure core Raemis is up and running before trying to configure UPF
    rsp_code="0";
    while [[ "$rsp_code" != 200 ]]; do
        rsp_code=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 3 --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} -X GET "https://${SMF_IP}:${SMF_API_PORT}/api/raemis");
        sleep 3;
    done;

    # Configure remote core
    # MGW_ID needs to be unique for each UPF - let's choose a random number and hope it doesn't conflict
    MGW_ID=$(shuf -i 2-1000000 -n 1)
    core_max_mgwendpoint_epid=$(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/mgw_ctrl_endpoint | jq 'sort_by(.ep_id)' | jq -r '.[-1].ep_id')
    max_mgwctrlendpointgroup_id=$(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/mgw_ctrl_endpoint_group | jq -r '.[-1].id')
    max_mgwctrlendpointgroup_id=$(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/mgw_ctrl_endpoint_group | jq -r '.[-1].id')
    new_mgwctrlendpointgroup_id=$((max_mgwctrlendpointgroup_id+1))
    max_epgroupid=$(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/mgw_ctrl_endpoint_group | jq -r '.[].ep_group_id' | sort -n | tail -1)
    new_epgroupid=$((max_epgroupid+1))
    if [ $(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/count/mgw_ctrl_endpoint_group?name=UPF_${MGW_ID} | jq -r '.[0]') -eq 0 ]; then
        curl -s -k -X POST --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/mgw_ctrl_endpoint_group -d "id"=${new_mgwctrlendpointgroup_id} -d "ctrl_id"=1 -d "name"=UPF_${MGW_ID} -d "ep_group_id"=${new_epgroupid} -d "type"=1

        # Need to choose next unique ep_id across both core and all UPFs
        upf_max_epid=$(sqlite3 /usr/share/raemis/db/raemis.db 'SELECT MAX(ep_id) FROM mgw_mgwendpoint')
        if [ ${core_max_mgwendpoint_epid} -gt ${upf_max_epid} ]; then max_epid=${core_max_mgwendpoint_epid}; else max_epid=${upf_max_epid}; fi;
        new_gtpu_epid=$((max_epid+1))
        curl -s -k -X POST --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/mgw_ctrl_endpoint -d "group_id"=1 -d "ep_id"=${new_gtpu_epid}
        new_bo_epid=$((max_epid+2))
        curl -s -k -X POST --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/mgw_ctrl_endpoint -d "group_id"=${new_mgwctrlendpointgroup_id} -d "ep_id"=${new_bo_epid}
    fi

    # Configure pdn related objects in core
    # Check if the ipv4_pool we want to use already exists in the core, if not create it.
    first_ip=$(echo ${IPV4_POOL} | cut -d "-" -f 1)
    last_ip=$(echo ${IPV4_POOL} | cut -d "-" -f 2)
    ipv4_pool_match_id=$(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} "https://${SMF_IP}:${SMF_API_PORT}/api/ipv4_pool?first_ip=${first_ip}&last_ip=${last_ip}" | jq -r '.[0].id')
    # if ipv4_pool_match_id empty then we need to create one and use it, otherwise use what was found
    if [ -z ${ipv4_pool_match_id} ]; then
        curl -s -k -X POST --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/ipv4_pool -d "first_ip"=${first_ip} -d "last_ip"=${last_ip}
        ipv4_pool_match_id=$(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} "https://${SMF_IP}:${SMF_API_PORT}/api/ipv4_pool?first_ip=${first_ip}&last_ip=${last_ip}" | jq -r '.[0].id')
    fi

    if [ $(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/count/pdn?apn=${UPF_SELECTION_DNN} | jq -r '.[0]') -eq 0 ]; then
        raemis_id=$(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} "https://${SMF_IP}:${SMF_API_PORT}/api/raemis" | jq -r '.[0].id')
        curl -s -k -X POST --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/pdn -d "apn"=${UPF_SELECTION_DNN} -d "primary_dns"=${PRIMARY_DNS} -d "secondary_dns"=${SECONDARY_DNS} -d "ipv4_pool_id"=${ipv4_pool_match_id} -d "ep_group_id"=${new_epgroupid} -d "raemis_id"=${raemis_id}
        curl -s -k -X POST --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/subscription_profile -d "name"=${UPF_SELECTION_DNN} -d "apn"=${UPF_SELECTION_DNN} -d "network_slice_id"=1
    fi

    # Trigger restart in remote core for config changes to take effect
    raemis_id=$(curl -s -k --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} "https://${SMF_IP}:${SMF_API_PORT}/api/raemis" | jq -r '.[0].id')
    curl -s -k -X PATCH --user ${SMF_API_USERNAME}:${SMF_API_PASSWORD} https://${SMF_IP}:${SMF_API_PORT}/api/raemis?id=1 -d 'admin_state=1'

    # Local UPF configuration
    sqlite3 /usr/share/raemis/db/raemis.db 'DELETE FROM mgw_ctrl_mgwctrlendpoint'
    sqlite3 /usr/share/raemis/db/raemis.db 'DELETE FROM mgw_ctrl_mgwctrlendpointgroup'
    sqlite3 /usr/share/raemis/db/raemis.db "UPDATE mgw_mgwendpoint SET ep_id=${new_gtpu_epid} WHERE id=1"
    sqlite3 /usr/share/raemis/db/raemis.db "UPDATE mgw_mgwendpoint SET ep_id=${new_bo_epid} WHERE id=2"
    sqlite3 /usr/share/raemis/db/raemis.db "CREATE TEMPORARY TABLE tmp_mgw_mgw AS SELECT * FROM mgw_mgw WHERE id=1;
UPDATE tmp_mgw_mgw SET id=${MGW_ID};
UPDATE tmp_mgw_mgw SET name='MGW_UPF_${MGW_ID}';
UPDATE tmp_mgw_mgw SET mgw_ctrl_net_device='${UPF_N4_NET_DEV}';
UPDATE tmp_mgw_mgw SET mgw_ctrl_url1='${SMF_IP}:${SMF_N4_PORT}';
UPDATE tmp_mgw_mgw SET application='raemis';
UPDATE tmp_mgw_mgw SET mgw_attr_2='${UPF_SELECTION_DNN}';
INSERT INTO mgw_mgw SELECT * FROM tmp_mgw_mgw;
DROP TABLE tmp_mgw_mgw;
"
    sqlite3 /usr/share/raemis/db/raemis.db "DELETE FROM mgw_mgwendpoint WHERE id>2"
    sqlite3 /usr/share/raemis/db/raemis.db "DELETE FROM gsn_pdn"
    sqlite3 /usr/share/raemis/db/raemis.db "DELETE FROM sgw_sgw"
    sqlite3 /usr/share/raemis/db/raemis.db "DELETE FROM lagw_localaccessgatewayrule"
    sqlite3 /usr/share/raemis/db/raemis.db "DELETE FROM cscf_cscf"
    sqlite3 /usr/share/raemis/db/raemis.db "UPDATE mgw_mgwendpoint SET mgw_id=${MGW_ID}"
    sqlite3 /usr/share/raemis/db/raemis.db "DELETE FROM mgw_mgw WHERE id=1"

    # Start raemis service again now that configuration has been made 
    systemctl start raemis

    echo "Waiting for Raemis GUI & API to start ..." | tee -a ${LOG_FILE}
    # Wait for Raemis to come up and API to start
    rsp_code="0";
    while [[ "$rsp_code" != 200 ]]; do
        rsp_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 --interface 127.0.0.2 -X GET "http://127.0.0.1/api/raemis"); 
        sleep 1;
    done;
    echo "Raemis GUI & API ready" | tee -a ${LOG_FILE}

    echo "Completed configuration for SOLUTION_TYPE ${SOLUTION_TYPE}" | tee -a ${LOG_FILE}
fi

echo "Restarting Raemis for changes to take effect" | tee -a ${LOG_FILE}
raemis_id=$(curl -s --interface 127.0.0.2 -X GET "http://127.0.0.1/api/raemis" | jq -r '.[0].id')
curl -s -o /dev/null --max-time 5 --interface 127.0.0.2 -X PATCH http://127.0.0.1/api/raemis?id=${raemis_id} -d 'admin_state=1' | tee -a ${LOG_FILE};

echo "Updating crontab with iptables MASQUERADE for default route interface N6 traffic" | tee -a ${LOG_FILE}
(crontab -l 2>/dev/null; echo "*/2 * * * * /sbin/iptables -C POSTROUTING -t nat -o \$(/sbin/ip route show default 0.0.0.0/0 | cut -d ' ' -f  5) -j MASQUERADE > /dev/null 2>&1; ret=\$?; if [ \$ret -ne 0 ]; then /sbin/iptables -A POSTROUTING -t nat -o \$(/sbin/ip route show default 0.0.0.0/0 | cut -d ' ' -f  5) -j MASQUERADE; fi") | crontab -

echo -e "Finished bootstrap script\n\n" | tee -a ${LOG_FILE}
