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

variable "cluster_kube_config_token_version"{
  default = "2.0.0"
}

variable "VCN-CIDR" {
  default = "10.0.0.0/16"
}

variable "cluster_options_kubernetes_network_config_pods_cidr" {
  default = "10.1.0.0/16"
}

variable "cluster_options_kubernetes_network_config_services_cidr" {
  default = "10.2.0.0/16"
}



variable "K8SAPIEndPointSubnet-CIDR" {
  default = "10.0.0.0/30"
}

variable "K8SLBSubnet-CIDR" {
  default = "10.0.2.0/24"
}

variable "K8SNodePoolSubnet-CIDR" {
  default = "10.0.1.0/24"
}

variable "Cluster-number"{
  default = 3
}


variable "node_pool_quantity_Cluster1" {
  default = 1
}

variable "node_pool_quantity_Cluster2" {
  default = 1
}

variable "node_pool_quantity_Cluster3" {
  default = 1
}


variable "node_pool1_size_Cluster1" {
  default = 2
}

variable "node_pool2_size_Cluster1" {
  default = 2
}

variable "node_pool_size_Cluster2" {
  default = 2
}

variable "node_pool1_size_Cluster3" {
  default = 2
}



variable "region_1" {
  default = "eu-frankfurt-1"
}

variable "region_2" {
  default = "eu-stockholm-1"
}

variable "region_3" {
  default = "eu-stockholm-1"
}



variable "ClusterName_1" {
  default = "OKECluster-1_Sweden"
}
variable "ClusterName_2" {
  default = "OKECluster-2_Frankfurt"
}
variable "ClusterName_3" {
  default = "OKECluster-3_Frankfurt"
}

variable "kubernetes_version_Cluster1" {
  default = "v1.26.2"
}

variable "kubernetes_version_Cluster2" {
  default = "v1.26.2"
}

variable "kubernetes_version_Cluster3" {
  default = "v1.26.2"
}

variable "instance_os" {
  default = "Oracle Linux"
}

variable "linux_os_version" {
  default = "8"
}

variable "Shape_1_pool1" {
  default = "VM.Standard.E3.Flex"
}

variable "Shape_1_pool2" {
  default = "VM.Standard.E3.Flex"
}

variable "Shape_2" {
  default = "VM.Standard3.Flex"
}


variable "Shape_3_pool1" {
  default = "VM.Standard3.Flex"
}



variable "Flex_shape_memory_Cluster1_pool1" {
  default = 6
}

variable "Flex_shape_memory_Cluster1_pool2" {
  default = 6
}

variable "Flex_shape_ocpus_Cluster1_pool1" {
  default = 1
}

variable "Flex_shape_ocpus_Cluster1_pool2" {
  default = 1
}

variable "Flex_shape_memory_Cluster2" {
  default = 6
}

variable "Flex_shape_ocpus_Cluster2" {
  default = 1
}

variable "Flex_shape_memory_Cluster3_pool1" {
  default = 5
}

variable "Flex_shape_ocpus_Cluster3_pool1" {
  default = 1
}









