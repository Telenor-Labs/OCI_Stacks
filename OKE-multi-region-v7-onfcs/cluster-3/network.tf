resource "oci_core_vcn" "VCN" {
  cidr_block     = var.VCN-CIDR
  compartment_id = var.compartment_ocid
  display_name   = "OKE-ORM-VCN-Telenor"
  default_security_list_id = null
}

# Service Gateway
resource "oci_core_service_gateway" "ServiceGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE-ORM-VCN-Public-EP-ServiceGateway"
  vcn_id         = oci_core_vcn.VCN.id
  services {
    service_id = lookup(data.oci_core_services.AllOCIServices.services[0], "id")
  }
}

# NAT Gateway
resource "oci_core_nat_gateway" "NATGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE-ORM-VCN-Public-EP-NATGateway"
  vcn_id         = oci_core_vcn.VCN.id
}

# Internet Gateway
resource "oci_core_internet_gateway" "InternetGateway" {
  compartment_id = var.compartment_ocid
  display_name   = "OKE-ORM-VCN-Public-EP-InternetGateway"
  vcn_id         = oci_core_vcn.VCN.id
}

# Route Table for K8s Public API Endpoint Subnet
resource "oci_core_route_table" "routetable-KubernetesAPIendpoint" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN.id
  display_name   = "routetable-KubernetesAPIendpoint"


  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.NATGateway.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.ServiceGateway.id
  }
}

# Route Table for OKE Worker Nodes Subnet
resource "oci_core_route_table" "routetable-workernodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN.id
  display_name   = "routetable-workernodes"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.NATGateway.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.ServiceGateway.id
  }
}

# Route Table for OKE Svc LB Subnet
resource "oci_core_route_table" "routetable-serviceloadbalancers" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN.id
  display_name   = "routetable-serviceloadbalancers"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.InternetGateway.id
  }
}

# Security List for K8s Public API Endpoint Subnet
resource "oci_core_security_list" "seclist-KubernetesAPIprivateendpoint" {
  compartment_id = var.compartment_ocid
  display_name   = "seclist-KubernetesAPIprivateendpoint"
  vcn_id         = oci_core_vcn.VCN.id

  # egress_security_rules

  egress_security_rules {               # Allow Kubernetes control plane to communicate with worker nodes.
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.K8SNodePoolSubnet-CIDR
  }

  egress_security_rules {             #Path Discovery on Worker Node pool.
    protocol         = 1
    destination_type = "CIDR_BLOCK"
    destination      = var.K8SNodePoolSubnet-CIDR

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {             #Path Discovery on regions OCI SERVICES.
    protocol         = 1
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {            # Allow Kubernetes control plane to communicate with OKE.
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")


    
  }

  # ingress_security_rules for private API endpoints

  ingress_security_rules {             #Kubernetes worker to Kubernetes API endpoint communication.
    protocol = "6"
    source   = var.K8SNodePoolSubnet-CIDR

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {             #Kubernetes worker to control plane communication.
    protocol = "6"
    source   = var.K8SNodePoolSubnet-CIDR

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {        #OCI Service access to Kubernetes API endpoint.
    protocol = "6"
	source_type = "SERVICE_CIDR_BLOCK"
    source   = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {        #External access to Kubernetes API endpoint.
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {         #Path Discovery from Worker Node pool
    protocol = 1
    source   = var.K8SLBSubnet-CIDR

    icmp_options {
      type = 3
      code = 4
    }
  }

}

resource "oci_core_security_list" "seclist-workernodes" {
  compartment_id = var.compartment_ocid
  display_name   = "seclist-workernodes"
  vcn_id         = oci_core_vcn.VCN.id


  # egress_security_rules

  egress_security_rules {              #Allow pods on one worker node to communicate with pods on other worker nodes.
    protocol         = "All"
    destination_type = "CIDR_BLOCK"
    destination      = var.K8SNodePoolSubnet-CIDR
  }

  egress_security_rules {
    protocol    = 1                    #ICMP path discovery
    destination = "10.0.0.0/16"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {                #Allow worker nodes to communicate with OKE.
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
  }

  egress_security_rules {              #Kubernetes worker to Kubernetes API endpoint communication.
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.K8SAPIEndPointSubnet-CIDR

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {                 #Kubernetes worker to control plane communication.
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.K8SAPIEndPointSubnet-CIDR

    tcp_options {
      min = 12250
      max = 12250
    }
  }

 
  # ingress_security_rules for worker node pool

  ingress_security_rules {   #Allow pods on one worker node to communicate with pods on other worker nodes.
    protocol = "All"
    source   = var.K8SNodePoolSubnet-CIDR
  }

  ingress_security_rules {   #Allow Kubernetes control plane to communicate with worker nodes.
    protocol = "6"
    source   = var.K8SAPIEndPointSubnet-CIDR
  }

  ingress_security_rules {  #Path discovery
    protocol = 1
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {   #Allow inbound SSH traffic to worker nodes from bastion Compute Instance.
    protocol = "6"
    source   = var.K8SLBSubnet-CIDR

    tcp_options {
      min = 22
      max = 22
    }
  }
  
  ingress_security_rules {   #Load balancer to worker nodes node ports.
    protocol = "6"
    source   = var.K8SLBSubnet-CIDR

    tcp_options {
      min = 30000
      max = 32767
    }
  }

  ingress_security_rules {   #Allow load balancer to communicate with kube-proxy on worker nodes
    protocol = "6"
    source   = var.K8SLBSubnet-CIDR

    tcp_options {
      min = 10256
      max = 10256
    }
  }

}


resource "oci_core_security_list" "seclist-loadbalancers" {
  compartment_id = var.compartment_ocid
  display_name   = "seclist-loadbalancers"
  vcn_id         = oci_core_vcn.VCN.id


  # egress_security_rules for service loadbalancers subnet


  egress_security_rules {              #Load balancer to worker nodes node ports
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.K8SNodePoolSubnet-CIDR

    tcp_options {
      min = 30000
      max = 32767
    }
  }

  egress_security_rules {                 #Allow load balancer to communicate with kube-proxy on worker nodes.
    protocol         = "6"
    destination_type = "CIDR_BLOCK"
    destination      = var.K8SNodePoolSubnet-CIDR

    tcp_options {
      min = 10256
      max = 10256
    }
  }

 

  # ingress_security_rules for service loadbalancers subnet
  # To allow SSH access on bastion node please add rule manually with your public ip as source ip to destination port 22  
 

}


#subnet creation

resource "oci_core_subnet" "K8SAPIEndPointSubnet" {
  cidr_block     = var.K8SAPIEndPointSubnet-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN.id
  display_name   = "K8SAPIEndPointSubnet"

  security_list_ids          = [oci_core_security_list.seclist-KubernetesAPIprivateendpoint.id]
  route_table_id             = oci_core_route_table.routetable-KubernetesAPIendpoint.id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "K8SLBSubnet" {
  cidr_block     = var.K8SLBSubnet-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN.id
  display_name   = "K8SLBSubnet"

  security_list_ids          = [oci_core_security_list.seclist-loadbalancers.id]
  route_table_id             = oci_core_route_table.routetable-serviceloadbalancers.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "K8SNodePoolSubnet" {
  cidr_block     = var.K8SNodePoolSubnet-CIDR
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN.id
  display_name   = "K8SNodePoolSubnet"

  security_list_ids          = [oci_core_security_list.seclist-workernodes.id]
  route_table_id             = oci_core_route_table.routetable-workernodes.id
  prohibit_public_ip_on_vnic = true
}


