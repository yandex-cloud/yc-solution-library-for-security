output "external_ip_address_remote" {
  value = yandex_compute_instance.remote-vpn.network_interface.0.nat_ip_address
}

output "external_ip_address_vpn" {
  value = yandex_compute_instance.cloud-vpn-gate.network_interface.0.nat_ip_address
}
