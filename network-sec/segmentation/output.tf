output "external_ip_address_dev" {
  value = yandex_compute_instance.vm-dev.network_interface.0.nat_ip_address
}

output "external_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "internal_ip_address_ci_cd" {
  value = yandex_compute_instance.vm-ci-cd.network_interface.0.ip_address
}

output "internal_ip_address_app_stage" {
  value = yandex_compute_instance.app-stage.network_interface.0.ip_address
}

output "internal_ip_address_app_prod" {
  value = yandex_compute_instance.app-prod.network_interface.0.ip_address
}
