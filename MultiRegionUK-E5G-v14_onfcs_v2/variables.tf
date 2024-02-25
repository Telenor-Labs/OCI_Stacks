variable "tenancy_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaagvacfoy6is3co4ekg3cpkpx5tfgf34xnbur4ivkxyerbny6b4bqq"
}
variable "user_ocid" {
  default = "ocid1.user.oc1..aaaaaaaatjxps5ia2syppc2irber2ddodo6os2eovtvzwcei3f6il2awz32q"
}

variable "compartment_ocid" {
  default = "ocid1.compartment.oc1..aaaaaaaamaovuoapidfy52u5vfvklgvhqq343rp4je3fmi3ju6kn72m7mr2q"
}

variable "availablity_domain_name" {
  default = ""
}

##5G CORE INFRA

variable "VCN-CIDR-Main" {
  default = "192.168.11.0/24"
}

variable "Druid_Public-CIDR-Main" {
  default = "192.168.11.0/26"
}

variable "RAN_N2_N3-CIDR-Main" {
  default = "192.168.11.64/26"
}

variable "WAN_N6-CIDR-Main" {
  default = "192.168.11.128/26"
}

variable "N4-CIDR-Main" {
  default = "192.168.11.192/26"
}

#UPF INFRA

variable "VCN-CIDR-Secondary" {
  default = "192.168.10.0/24"
}

variable "Druid_Public-CIDR-Secondary" {
  default = "192.168.10.0/26"
}

variable "RAN_N3-CIDR-Secondary" {
  default = "192.168.10.64/26"
}

variable "WAN_N6-CIDR-Secondary" {
  default = "192.168.10.128/26"
}

variable "N4-CIDR-Secondary" {
  default = "192.168.10.192/26"
}

##MAIN 5G CORE
variable "region_5g" {
  default = ""
}

/*variable "region_upf" {
  default = ""
}*/

variable "region_upf1" {
  default = "uk-cardiff-1" 
}

variable "region_upf2" {
  default = "eu-stockholm-1" 
}

variable "region_upf3" {
  default = "ap-hyderabad-1" 
}

variable "upf_count" {
  default = 0
}
variable "No-of-Active-sessions" {
  default = "20000"
}

variable "No-of-Concurrent-VoLTE-VoNR-calls" {
  default = "40"
}

variable "Total_throughput" {
  default = "2"
}

variable "raemis_oam" {
  default = 2
}

variable "Shape" {
  default = "VM.Standard.E4.Flex"
}

variable "Image_5g" {
  default = "ocid1.image.oc1.uk-london-1.aaaaaaaa5ntcdcwerbkj3khprgrvp3h6cs332bj54lkqogfxtchkvpybnata"
}


locals {
  config_ocpus = ceil((var.No-of-Active-sessions/20000)+(var.Total_throughput/2.5)+(var.No-of-Concurrent-VoLTE-VoNR-calls/40) + (var.raemis_oam))
  
}


locals {
  memory_in_gbs = 20 #fix it
  
}

variable "MCC" {
  default = "101"
}

variable "MNC" {
  default = "10"
}

variable "SST" {
  default = ""
}

variable "SD" {
  default = ""
}

variable "RAN_CP" {
  default = "ens5"
}

variable "RAN_DP" {
  default = "ens5"
}

variable "WAN" {
  default = "ens6"
}

variable "N4" {
  default = "ens7"
}

variable "WEB_TOKEN_IDENTITY" {
  default = "1"
}

variable "NMS_IDENTITY_5g" {
  default = "50dd7036-7791-4db3-9c15-d8d525e1ff56"
}

variable "NMS_IP" {
  default = "129.151.192.161"
}

variable "SOLUTION_TYPE_5g" {
  default = "pcn"
}

variable "Type_of_edge1" {
  default = ""
}

variable "Type_of_edge2" {
  default = ""
}

variable "Type_of_edge3" {
  default = ""
}
#UPF1


variable "Image_upf1" {
  
  default = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaaiywzsrkotyahydnqjdvudhc4okzjpfm6nqbto7mtdxlfypjhfnfa"
}


variable "NMS_IDENTITY_upf1" {
  
  default = "658a431b-019d-4169-8fc9-dd4590904abb"
} 

variable "SOLUTION_TYPE_upf1" {
  default = "upf"
}

variable "SMF_IP1" {

  default = "192.168.11.196"
}

variable "SMF_API_USERNAME1" {
 
  default = "raemis"
}

variable "SMF_API_PASSWORD1" {
  
  default = "password"
}

variable "UPF_SELECTION_DNN1" {
 
  default = "Cardiff"
}

#UPF2


variable "Image_upf2" {
  
  default = ""
}


variable "NMS_IDENTITY_upf2" {
  
  default = ""
} 

variable "SOLUTION_TYPE_upf2" {
  default = "upf"
}

variable "SMF_IP2" {

  default = "192.168.11.196"
}

variable "SMF_API_USERNAME2" {
 
  default = "raemis"
}

variable "SMF_API_PASSWORD2" {
  
  default = "password"
}

variable "UPF_SELECTION_DNN2" {
 
  default = ""
}

#UPF3


variable "Image_upf3" {
  
  default = ""
}


variable "NMS_IDENTITY_upf3" {
  
  default = ""
} 

variable "SOLUTION_TYPE_upf3" {
  default = "upf"
}

variable "SMF_IP3" {

  default = "192.168.11.196"
}

variable "SMF_API_USERNAME3" {
 
  default = "raemis"
}

variable "SMF_API_PASSWORD3" {
  
  default = "password"
}

variable "UPF_SELECTION_DNN3" {
 
  default = ""
}

#LIST

locals {

Image_upf =["${var.Image_upf1}","${var.Image_upf2}","${var.Image_upf3}"]
  

NMS_IDENTITY_upf = ["${var.NMS_IDENTITY_upf1}","${var.NMS_IDENTITY_upf2}","${var.NMS_IDENTITY_upf3}"]
  
SOLUTION_TYPE_upf = ["${var.SOLUTION_TYPE_upf1}","${var.SOLUTION_TYPE_upf2}","${var.SOLUTION_TYPE_upf3}"]

SMF_IP = ["${var.SMF_IP1}","${var.SMF_IP2}","${var.SMF_IP3}"]

SMF_API_USERNAME = ["${var.SMF_API_USERNAME1}","${var.SMF_API_USERNAME2}","${var.SMF_API_USERNAME3}"]

SMF_API_PASSWORD = ["${var.SMF_API_PASSWORD1}","${var.SMF_API_PASSWORD2}","${var.SMF_API_PASSWORD3}"]

UPF_SELECTION_DNN = ["${var.UPF_SELECTION_DNN1}","${var.UPF_SELECTION_DNN2}","${var.UPF_SELECTION_DNN3}"]

region_upf = ["${var.region_upf1}","${var.region_upf2}","${var.region_upf3}"]


}

#UE

variable "testing" {
  type = bool
}

variable "config_ocpus_ue" {
  default = 1
}
variable "memory_in_gbs_ue" {
  default = 2
}
variable "Shape_ue" {
  default = "VM.Standard.E4.Flex"
}
variable "Image_ue" {
  default = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaaprzq5lsdagpogvehhuh5havc3eczecnqiccetsqxbksok23pakma"
}
variable "config_ocpus-test" {
  default = 1
}
variable "memory_in_gbs-test" {
  default = 2
}
variable "Shape-test" {
  default = "VM.Standard.A1.Flex"
}
variable "Image-test" {
  default = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaahdomtfesmtvkfk664mulzcvrpxuirj7txfvolc4lucj6u6te2ycq"
}