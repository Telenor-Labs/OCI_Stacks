resource "oci_dns_view" "test_view" {
    depends_on = [oci_core_vcn.VCN]
    compartment_id = var.compartment_ocid
    scope = "PRIVATE"
    display_name = "OKE-Telenor"
    
}

resource "oci_dns_zone" "home_zone" {
    depends_on = [oci_core_vcn.VCN]
    name = var.domain_name
    compartment_id = var.compartment_ocid
    zone_type = "PRIMARY"
    scope = "PRIVATE"
    view_id = oci_dns_view.test_view.id
}

resource "oci_dns_zone" "onprem_zone" {
    depends_on = [oci_core_vcn.VCN]
    name = var.onpremdomain_name
    compartment_id = var.compartment_ocid
    zone_type = "PRIMARY"
    scope = "PRIVATE"
    view_id = oci_dns_view.test_view.id
}

resource "oci_dns_rrset" "test_rrset_ausf" {
    #Required
    domain = "${var.fqdn}"
    rtype = "A"
    zone_name_or_id = oci_dns_zone.onprem_zone.id

    #Optional
    compartment_id = var.compartment_ocid
    items {
        #Required
        domain = "${var.fqdn}"
        rdata = "${var.onprem_ip}"
        rtype = "A"
        ttl = "3600"
    }
    
}