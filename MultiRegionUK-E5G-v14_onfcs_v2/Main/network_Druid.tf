
## VCN CREATION
resource "oci_core_vcn" "VCN-1" {
  cidr_block     = var.VCN-CIDR
  compartment_id = var.compartment_ocid
  dns_label = "e5gvcnmainSite"
  display_name   = "E5G_VCN_MainSite"
 
}

## DRG
resource "oci_core_drg" "DRG-1" {
  compartment_id = var.compartment_ocid
  display_name   = "DRG-mainSite"
}

##DRG ATTACHMENT
resource "oci_core_drg_attachment" "DRGAttachment-1" {
  drg_id       = oci_core_drg.DRG-1.id
  vcn_id       = oci_core_vcn.VCN-1.id
  display_name = "DRGAttachment-1"
}

##SERVICE GATEWAY
resource "oci_core_service_gateway" "ServiceGateway-1" {
  compartment_id = var.compartment_ocid
  display_name   = "ServiceGateway"
  vcn_id         = oci_core_vcn.VCN-1.id
  services {
    service_id = lookup(data.oci_core_services.AllOCIServices.services[0], "id")
  }
}

##NAT GATEWAY
/*resource "oci_core_nat_gateway" "NATGateway-1" {
  compartment_id = var.compartment_ocid
  display_name   = "NATGateway"
  vcn_id         = oci_core_vcn.VCN-1.id
}*/

# INTERNET GATEWAY

resource "oci_core_internet_gateway" "InternetGateway-1" {
  compartment_id = var.compartment_ocid
  display_name   = "InternetGateway"
  vcn_id         = oci_core_vcn.VCN-1.id
}

##DEFAULT ROUTE TABLE

resource "oci_core_default_route_table" "default-route-table" {
  compartment_id = var.compartment_ocid
  manage_default_resource_id = oci_core_vcn.VCN-1.default_route_table_id
  display_name   = "Default Route Table for E5G_VCN_mainSite"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.InternetGateway-1.id
  }

  route_rules {
    destination       = "192.168.10.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.DRG-1.id
  }
}



##DEFAULT SECURITY LIST

resource "oci_core_default_security_list" "default-security-list-1" {
  compartment_id = var.compartment_ocid
  manage_default_resource_id = oci_core_vcn.VCN-1.default_security_list_id
  display_name   = "Default Security list for E5G_VCN_mainSite"

  # ingress_security_rules for private API endpoints

  ingress_security_rules {             #Kubernetes worker to Kubernetes API endpoint communication.
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {         #Path Discovery from Worker Node pool
    protocol = 1
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {             #Kubernetes worker to Kubernetes API endpoint communication.
    protocol = "All"
    source   = "192.168.0.0/16"

  }
  egress_security_rules {              #Load balancer to worker nodes node ports
    protocol         = "All"
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
  }

}


#subnet creation

#Druid_Public
resource "oci_core_subnet" "Druid_Public" {
  cidr_block     = var.Druid_Public-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN-1.id
  display_name   = "Public_mainSite"

  security_list_ids          = [oci_core_default_security_list.default-security-list-1.id]
  route_table_id             = oci_core_default_route_table.default-route-table.id
  prohibit_public_ip_on_vnic = false
}

##RAN_N2_N3

resource "oci_core_subnet" "RAN_N2_N3" {
  cidr_block     = var.RAN_N2_N3-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN-1.id
  display_name   = "RAN_N2_N3"

  security_list_ids          = [oci_core_default_security_list.default-security-list-1.id]
  route_table_id             = oci_core_default_route_table.default-route-table.id
  prohibit_public_ip_on_vnic = true
}

##WAN_N6
resource "oci_core_subnet" "WAN_N6" {
  cidr_block     = var.WAN_N6-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN-1.id
  display_name   = "WAN_N6_mainSite"

  security_list_ids          = [oci_core_default_security_list.default-security-list-1.id]
  route_table_id             = oci_core_default_route_table.default-route-table.id
  prohibit_public_ip_on_vnic = true
}

#N4

resource "oci_core_subnet" "N4" {
  cidr_block     = var.N4-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN-1.id
  display_name   = "N4_mainSite"

  security_list_ids          = [oci_core_default_security_list.default-security-list-1.id]
  route_table_id             = oci_core_default_route_table.default-route-table.id
  prohibit_public_ip_on_vnic = true
}

## RPC

resource "oci_core_remote_peering_connection" "peering_connection" {
    #Required
    compartment_id = var.compartment_ocid
    drg_id = oci_core_drg.DRG-1.id

    display_name = "RPC_to_Secondarysite"
    
}







