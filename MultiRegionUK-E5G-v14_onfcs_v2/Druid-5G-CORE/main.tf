resource "oci_core_instance" "TFInstance" {
    # Required
    availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
    compartment_id = var.compartment_ocid
    shape = var.Shape
    shape_config {
        memory_in_gbs = var.memory_in_gbs
        ocpus = var.config_ocpus
    }
    source_details {
        source_id = var.Image
        source_type = "image"
    }

    # Optional
    display_name = "Druid-5G-Core"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = var.Public-Subnet
    }
    
    metadata = {
        ssh_authorized_keys = file("${path.module}/files/occ_onfcs_bastion.pub")
    } 
    preserve_boot_volume = false
}

resource "oci_core_vnic_attachment" "vnic-1" {
  create_vnic_details {
    display_name  = "N2_N3"
    subnet_id     = var.Subnet-N2_N3
    private_ip = "192.168.11.98"
    defined_tags  = {}
  }
  display_name = "N2_N3"
  instance_id  = oci_core_instance.TFInstance.id
}

resource "oci_core_vnic_attachment" "vnic-2" {
  depends_on = [oci_core_vnic_attachment.vnic-1]
  create_vnic_details {
    display_name  = "N6"
    subnet_id     = var.Subnet-N6
    private_ip = "192.168.11.174"
    defined_tags  = {}
  }
  display_name = "N6"
  instance_id  = oci_core_instance.TFInstance.id
}

resource "oci_core_vnic_attachment" "vnic-3" {
  depends_on = [oci_core_vnic_attachment.vnic-2]
  create_vnic_details {
    display_name  = "N4"
    subnet_id     = var.Subnet-N4
    private_ip = "192.168.11.196"
    defined_tags  = {}
  }
  display_name = "N4"
  instance_id  = oci_core_instance.TFInstance.id
}

resource "null_resource" "remote-exec" {
  depends_on = [oci_core_instance.TFInstance,oci_core_vnic_attachment.vnic-1,oci_core_vnic_attachment.vnic-2,oci_core_vnic_attachment.vnic-3]

  provisioner "file" {
    source      = "${path.module}/files/secondary_vnic_all_configure.sh"
    destination = "secondary_vnic_all_configure.sh"
  
    connection {
      host     = "${oci_core_instance.TFInstance.public_ip}"
      type     = "ssh"
      user     = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
      agent    = "false"
    }
 }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${oci_core_instance.TFInstance.public_ip}"
      user        = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
    }
  
    inline = [
      "chmod 777 secondary_vnic_all_configure.sh"
    ]
  } 
}


resource "time_sleep" "wait_1min" {
  depends_on = [null_resource.remote-exec]
  create_duration = "60s"
}
resource "null_resource" "remote-exec-1"{
  depends_on = [time_sleep.wait_1min]
  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${oci_core_instance.TFInstance.public_ip}"
      user        = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
    }
    inline = [
      "sudo ./secondary_vnic_all_configure.sh -c"
    ]
 }
  
}


resource "local_file" "raemis-bootstrap-config" {
  content = <<-EOT
  RAN_CP="${var.RAN_CP}"
  RAN_DP="${var.RAN_DP}"
  WAN="${var.WAN}"
  N4="${var.N4}"
  MCC="${var.MCC}"
  MNC="${var.MNC}"
  WEB_TOKEN_IDENTITY="${var.WEB_TOKEN_IDENTITY}"
  NMS_IDENTITY="${var.NMS_IDENTITY}"
  NMS_IP="${var.NMS_IP}"
  EOT
  filename = "${path.module}/files/raemis/raemis_bootstrap_config.env"
}



resource "null_resource" "raemis-file-copy-1"{
  depends_on = [local_file.raemis-bootstrap-config,null_resource.remote-exec-1]

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${oci_core_instance.TFInstance.public_ip}"
      user        = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
    }
  
    inline = [
      "sudo chmod a+w /etc/raemis/"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/raemis/"
    destination = "/etc/raemis"
  
    connection {
      host     = "${oci_core_instance.TFInstance.public_ip}"
      type     = "ssh"
      user     = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
      agent    = "false"
    }
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${oci_core_instance.TFInstance.public_ip}"
      user        = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
    }
  
    inline = [
      "sudo chmod a-w /etc/raemis/"
    ]
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${oci_core_instance.TFInstance.public_ip}"
      user        = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
    }
  
    inline = [
      "sudo chmod a+w /usr/local/bin",
      "sudo mv /etc/raemis/raemis_bootstrap.sh /usr/local/bin/",
      "sudo chmod a-w /usr/local/bin",
      "sudo chmod u+x /usr/local/bin/raemis_bootstrap.sh"
    ]
  }
}

resource "null_resource" "remote-exec-temp"{
  depends_on = [null_resource.raemis-file-copy-1]
  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${oci_core_instance.TFInstance.public_ip}"
      user        = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
    }
    inline = [
      "sudo yum -y install dos2unix","sudo dos2unix /etc/raemis/raemis_bootstrap_config.env"
    ]
 }
  
}
resource "null_resource" "remote-exec-2"{
  depends_on = [null_resource.remote-exec-temp]
  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${oci_core_instance.TFInstance.public_ip}"
      user        = "opc"
      private_key = file("${path.module}/files/occ_onfcs_bastion.key")
    }
    inline = [
      "sudo /usr/local/bin/raemis_bootstrap.sh -t ${var.SOLUTION_TYPE}"
    ]
 }
  
}
