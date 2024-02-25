module "Main" {
  source       = "./Main"
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =var.region_5g
  availablity_domain_name =var.availablity_domain_name
  VCN-CIDR = var.VCN-CIDR-Main
  Druid_Public-CIDR = var.Druid_Public-CIDR-Main
  RAN_N2_N3-CIDR = var.RAN_N2_N3-CIDR-Main
  WAN_N6-CIDR = var.WAN_N6-CIDR-Main
  N4-CIDR = var.N4-CIDR-Main

  providers = {
    oci = oci.reg1
  }
}

module "Secondary" {
  depends_on = [module.Main]
  source       = "./Secondary"
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =local.region_upf[0]
  region1 =var.region_5g
  availablity_domain_name = var.availablity_domain_name
  VCN-CIDR = var.VCN-CIDR-Secondary
  Druid_Public-CIDR = var.Druid_Public-CIDR-Secondary
  RAN_N3-CIDR = var.RAN_N3-CIDR-Secondary
  WAN_N6-CIDR = var.WAN_N6-CIDR-Secondary
  N4-CIDR = var.N4-CIDR-Secondary
  rpc_id = "${module.Main.rpc_id}"

    
  providers = {
    oci = oci.reg2
  }
}
module "Druid-5G-CORE" {
  source       = "./Druid-5G-CORE"
  depends_on = [module.Main]
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =var.region_5g
  availablity_domain_name =var.availablity_domain_name
  No-of-Subscribers = var.No-of-Active-sessions
  config_ocpus = local.config_ocpus
  memory_in_gbs = local.memory_in_gbs
  Shape         = var.Shape
  Image         = var.Image_5g
  VCN           = "${module.Main.vcn_id}"
  Subnet-N2_N3  = "${module.Main.n2_n3_id}"
  Public-Subnet = "${module.Main.public_id}"
  Subnet-N6     = "${module.Main.n6_id}"
  Subnet-N4     = "${module.Main.n4_id}"
  MCC                 = var.MCC               
  MNC                 = var.MNC               
  SST                 = var.SST               
  SD                  = var.SD                
  RAN_CP              = var.RAN_CP            
  RAN_DP              = var.RAN_DP            
  WAN                 = var.WAN               
  N4                  = var.N4                
  WEB_TOKEN_IDENTITY  = var.WEB_TOKEN_IDENTITY
  NMS_IDENTITY        = var.NMS_IDENTITY_5g     
  NMS_IP              = var.NMS_IP            
  SOLUTION_TYPE       = var.SOLUTION_TYPE_5g 

  providers = {
    oci = oci.reg1
  }
      
}

module "Druid-UPF1" {
  count  = var.upf_count > 0 && var.Type_of_edge1 == "UPF only" ? 1 : 0 
  depends_on = [module.Secondary,module.Druid-5G-CORE]
  source       = "./Druid-UPF"
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =  local.region_upf[0]
  availablity_domain_name = var.availablity_domain_name
  No-of-Subscribers = var.No-of-Active-sessions
  config_ocpus = local.config_ocpus
  memory_in_gbs = local.memory_in_gbs
  Shape         = var.Shape
  Image         = local.Image_upf[0]
  VCN           = "${module.Secondary.vcn_id}"
  Subnet-N3     = "${module.Secondary.n3_id}"
  Public-Subnet = "${module.Secondary.public_id}"
  Subnet-N6     = "${module.Secondary.n6_id}"
  Subnet-N4     = "${module.Secondary.n4_id}"
  MCC                 = var.MCC               
  MNC                 = var.MNC               
  SST                 = var.SST               
  SD                  = var.SD                
  RAN_CP              = var.RAN_CP            
  RAN_DP              = var.RAN_DP            
  WAN                 = var.WAN               
  N4                  = var.N4 
  WEB_TOKEN_IDENTITY  = var.WEB_TOKEN_IDENTITY
  NMS_IDENTITY        = local.NMS_IDENTITY_upf[0]      
  NMS_IP              = var.NMS_IP            
  SOLUTION_TYPE       = local.SOLUTION_TYPE_upf[0]
  SMF_IP              = local.SMF_IP[0]
  SMF_API_USERNAME    = local.SMF_API_USERNAME[0]
  SMF_API_PASSWORD    = local.SMF_API_PASSWORD[0]
  UPF_SELECTION_DNN   = local.UPF_SELECTION_DNN[0]

  providers = {
    oci = oci.reg2
  }

}

module "Druid-UPF2" {
  count  = var.upf_count > 1 && var.Type_of_edge2 == "UPF only"  ? 1 : 0 
  depends_on = [module.Druid-5G-CORE]
  source       = "./Druid-UPF"
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =  local.region_upf[1]
  availablity_domain_name = var.availablity_domain_name
  No-of-Subscribers = var.No-of-Active-sessions
  config_ocpus = local.config_ocpus
  memory_in_gbs = local.memory_in_gbs
  Shape         = var.Shape
  Image         = local.Image_upf[1]
  VCN           = "${module.Secondary.vcn_id}"
  Subnet-N3     = "${module.Secondary.n3_id}"
  Public-Subnet = "${module.Secondary.public_id}"
  Subnet-N6     = "${module.Secondary.n6_id}"
  Subnet-N4     = "${module.Secondary.n4_id}"
  MCC                 = var.MCC               
  MNC                 = var.MNC               
  SST                 = var.SST               
  SD                  = var.SD                
  RAN_CP              = var.RAN_CP            
  RAN_DP              = var.RAN_DP            
  WAN                 = var.WAN               
  N4                  = var.N4 
  WEB_TOKEN_IDENTITY  = var.WEB_TOKEN_IDENTITY
  NMS_IDENTITY        = local.NMS_IDENTITY_upf[1]      
  NMS_IP              = var.NMS_IP            
  SOLUTION_TYPE       = local.SOLUTION_TYPE_upf[1]
  SMF_IP              = local.SMF_IP[1]
  SMF_API_USERNAME    = local.SMF_API_USERNAME[1]
  SMF_API_PASSWORD    = local.SMF_API_PASSWORD[1]
  UPF_SELECTION_DNN   = local.UPF_SELECTION_DNN[1]

  providers = {
    oci = oci.reg3
  }

}

module "Druid-UPF3" {
  count  = var.upf_count > 2 && var.Type_of_edge3 == "UPF only" ? 1 : 0 
  depends_on = [module.Druid-5G-CORE]
  source       = "./Druid-UPF"
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =  local.region_upf[2]
  availablity_domain_name = var.availablity_domain_name
  No-of-Subscribers = var.No-of-Active-sessions
  config_ocpus = local.config_ocpus
  memory_in_gbs = local.memory_in_gbs
  Shape         = var.Shape
  Image         = local.Image_upf[2]
  VCN           = "${module.Secondary.vcn_id}"
  Subnet-N3     = "${module.Secondary.n3_id}"
  Public-Subnet = "${module.Secondary.public_id}"
  Subnet-N6     = "${module.Secondary.n6_id}"
  Subnet-N4     = "${module.Secondary.n4_id}"
  MCC                 = var.MCC               
  MNC                 = var.MNC               
  SST                 = var.SST               
  SD                  = var.SD                
  RAN_CP              = var.RAN_CP            
  RAN_DP              = var.RAN_DP            
  WAN                 = var.WAN               
  N4                  = var.N4 
  WEB_TOKEN_IDENTITY  = var.WEB_TOKEN_IDENTITY
  NMS_IDENTITY        = local.NMS_IDENTITY_upf[2]      
  NMS_IP              = var.NMS_IP            
  SOLUTION_TYPE       = local.SOLUTION_TYPE_upf[2]
  SMF_IP              = local.SMF_IP[2]
  SMF_API_USERNAME    = local.SMF_API_USERNAME[2]
  SMF_API_PASSWORD    = local.SMF_API_PASSWORD[2]
  UPF_SELECTION_DNN   = local.UPF_SELECTION_DNN[2]

  providers = {
    oci = oci.reg4
  }

}

module "UE" {
  source       = "./UE"
  count = var.testing ? 1:0
  depends_on = [module.Secondary]
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region = local.region_upf[0]
  availablity_domain_name =var.availablity_domain_name
  config_ocpus_ue = var.config_ocpus_ue
  memory_in_gbs_ue = var.memory_in_gbs_ue
  Shape_ue         = var.Shape_ue
  Image_ue         = var.Image_ue
  config_ocpus-test = var.config_ocpus-test
  memory_in_gbs-test = var.memory_in_gbs-test
  Shape-test         = var.Shape-test
  Image-test         = var.Image-test
  VCN           = "${module.Secondary.vcn_id}"
  Subnet-N3     = "${module.Secondary.n3_id}"
  Public-Subnet = "${module.Secondary.public_id}"
  Subnet-N6     = "${module.Secondary.n6_id}"
  providers = {
    oci = oci.reg2
  }
      
}

