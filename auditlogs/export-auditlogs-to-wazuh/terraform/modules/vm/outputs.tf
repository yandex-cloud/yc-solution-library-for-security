output "vm_public_ip" {
  description = "Virtual Machine public ip address"
  value       = try(yandex_compute_instance.instance[0].network_interface.0.nat_ip_address, "")

}
output "vm_private_ip" {
  description = "Virtual Machine private ip address"
  value       = try(yandex_compute_instance.instance[0].network_interface.0.ip_address, "")
}
output "metadata" {
  value = yandex_compute_instance.instance[0].metadata
}
