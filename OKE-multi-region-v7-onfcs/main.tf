module "cluster-1" {
  
  source       = "./cluster-1"
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =var.region_1
  availablity_domain_name =var.availablity_domain_name
  VCN-CIDR = var.VCN-CIDR
  cluster_options_kubernetes_network_config_pods_cidr = var.cluster_options_kubernetes_network_config_pods_cidr
  cluster_options_kubernetes_network_config_services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
  cluster_kube_config_token_version = var.cluster_kube_config_token_version
  K8SAPIEndPointSubnet-CIDR = var.K8SAPIEndPointSubnet-CIDR
  K8SLBSubnet-CIDR = var.K8SLBSubnet-CIDR
  K8SNodePoolSubnet-CIDR = var.K8SNodePoolSubnet-CIDR
  node_pool_quantity = var.node_pool_quantity_Cluster1
  cluster_type = var.cluster_type1
  kubernetes_version = var.kubernetes_version_Cluster1
  instance_os = var.instance_os
  linux_os_version = var.linux_os_version
  node_pools = [
  { Shape_1 = var.Shape_1_pool1
    size = var.node_pool1_size_Cluster1
    name = "pool1"
    Flex_shape_memory = var.Flex_shape_memory_Cluster1_pool1
    Flex_shape_ocpus = var.Flex_shape_ocpus_Cluster1_pool1
    kubernetes_version = var.kubernetes_version_Cluster1_pool1
  },
  { Shape_1 = var.Shape_1_pool2
    size = var.node_pool2_size_Cluster1
    name = "pool2"
    Flex_shape_memory = var.Flex_shape_memory_Cluster1_pool2
    Flex_shape_ocpus = var.Flex_shape_ocpus_Cluster1_pool2
    kubernetes_version = var.kubernetes_version_Cluster1_pool2
  }
  ]
  ClusterName = var.ClusterName_1
  onpremdomain_name = var.onpremdomain_name
  domain_name = var.domain_name
  fqdn = var.fqdn
  onprem_ip = var.onprem_ip
      

  providers = {
    oci = oci.home
  }
}

module "cluster-2" {
  
  source       = "./cluster-2"
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =var.region_2
  availablity_domain_name = var.availablity_domain_name
  VCN-CIDR = var.VCN-CIDR
  cluster_options_kubernetes_network_config_pods_cidr = var.cluster_options_kubernetes_network_config_pods_cidr
  cluster_options_kubernetes_network_config_services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
  cluster_kube_config_token_version = var.cluster_kube_config_token_version
  K8SAPIEndPointSubnet-CIDR = var.K8SAPIEndPointSubnet-CIDR
  K8SLBSubnet-CIDR = var.K8SLBSubnet-CIDR
  K8SNodePoolSubnet-CIDR = var.K8SNodePoolSubnet-CIDR
  node_pool_quantity = var.node_pool_quantity_Cluster2
  kubernetes_version = var.kubernetes_version_Cluster2
  node_pool_size = var.node_pool_size_Cluster2
  instance_os = var.instance_os
  linux_os_version = var.linux_os_version
  Shape = var.Shape_2
  Flex_shape_memory = var.Flex_shape_memory_Cluster2
  Flex_shape_ocpus = var.Flex_shape_ocpus_Cluster2
  ClusterName = var.ClusterName_2
  cluster_type = var.cluster_type2
      
  providers = {
    oci = oci.arn
  }
}
module "cluster-3" {
  
  source       = "./cluster-3"
  tenancy_ocid =var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  user_ocid =var.user_ocid
  region =var.region_3
  availablity_domain_name = var.availablity_domain_name
  VCN-CIDR = var.VCN-CIDR
  cluster_options_kubernetes_network_config_pods_cidr = var.cluster_options_kubernetes_network_config_pods_cidr
  cluster_options_kubernetes_network_config_services_cidr = var.cluster_options_kubernetes_network_config_services_cidr
  cluster_kube_config_token_version = var.cluster_kube_config_token_version
  K8SAPIEndPointSubnet-CIDR = var.K8SAPIEndPointSubnet-CIDR
  K8SLBSubnet-CIDR = var.K8SLBSubnet-CIDR
  K8SNodePoolSubnet-CIDR = var.K8SNodePoolSubnet-CIDR
  node_pool_quantity = var.node_pool_quantity_Cluster3
  kubernetes_version = var.kubernetes_version_Cluster3
  instance_os = var.instance_os
  linux_os_version = var.linux_os_version
  node_pools = [
  { Shape_3 = var.Shape_3_pool1
    size = var.node_pool1_size_Cluster3
    name = "pool1"
  }
  ]
  Flex_shape_memory = var.Flex_shape_memory_Cluster3_pool1
  Flex_shape_ocpus = var.Flex_shape_ocpus_Cluster3_pool1
  ClusterName = var.ClusterName_3
  cluster_type = var.cluster_type2
      

  providers = {
    oci = oci.phx
  }
}