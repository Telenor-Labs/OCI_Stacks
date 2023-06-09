provider "oci" {
  auth = "InstancePrincipal"
  alias            = "home"
  region           = var.region_1
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  
}

provider "oci" {
  auth = "InstancePrincipal"
  alias            = "arn"
  region           = var.region_2
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
}

provider "oci" {
  alias            = "phx"
  region           = var.region_3
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
}