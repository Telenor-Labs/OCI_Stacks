provider "oci" {
  
  alias            = "reg1"
  region           = var.region_5g
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  
}



provider "oci" {
   
  alias            = "reg2"
  region           = local.region_upf[0]
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  
}
provider "oci" {
   
  alias            = "reg3"
  region           = local.region_upf[1]
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  
}
provider "oci" {
   
  alias            = "reg4"
  region           = local.region_upf[2]
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  
}

