output "rpc_id" {
  value = oci_core_remote_peering_connection.peering_connection.id
}

output "vcn_id" {
  value = oci_core_vcn.VCN-1.id
}

output "public_id" {
  value = oci_core_subnet.Druid_Public.id
}

output "n2_n3_id" {
  value = oci_core_subnet.RAN_N2_N3.id
}

output "n6_id" {
  value = oci_core_subnet.WAN_N6.id
}

output "n4_id" {
  value = oci_core_subnet.N4.id
}