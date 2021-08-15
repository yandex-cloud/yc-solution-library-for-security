output "external_ip" {
  value = yandex_compute_instance.instance-based-on-coi.network_interface.0.nat_ip_address
}