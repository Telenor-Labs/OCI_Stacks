resource "oci_core_instance" "TFInstance" {
    # Required
    availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
    compartment_id = var.compartment_ocid
    shape = var.Shape_ue
    shape_config {
        memory_in_gbs = var.memory_in_gbs_ue
        ocpus = var.config_ocpus_ue
    }
    source_details {
        source_id = var.Image_ue
        source_type = "image"
    }

    # Optional
    display_name = "UERANsim"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = var.Public-Subnet
        private_ip = "192.168.10.12"
    }
    
    metadata = {
        ssh_authorized_keys = file("${path.module}/files/occ_onfcs_bastion.pub")
    } 
    preserve_boot_volume = false
}

resource "oci_core_instance" "VMInstance" {
    # Required
    availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
    compartment_id = var.compartment_ocid
    shape = var.Shape-test
    shape_config {
        memory_in_gbs = var.memory_in_gbs-test
        ocpus = var.config_ocpus-test
    }
    source_details {
        source_id = var.Image-test
        source_type = "image"
    }

    # Optional
    display_name = "TestVM"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = var.Public-Subnet
    }
    
    metadata = {
        ssh_authorized_keys = file("${path.module}/files/occ_onfcs_bastion.pub")
    } 
    preserve_boot_volume = false
}




