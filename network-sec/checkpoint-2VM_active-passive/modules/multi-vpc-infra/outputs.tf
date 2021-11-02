output "target_group_id" {
  description = "Target group id that is created by module"
  value       = yandex_lb_target_group.router_switcher_tg.id
}

output "load_balancer_id" {
  description = "Load Balancer id that is created by module"

  value = yandex_lb_network_load_balancer.router_switcher_lb.id
}


output "bucket_id" {
  description = "Bucket id that is created by module"

  value = yandex_storage_bucket.route_switcher_bucket.id
}



output "access_key" {
  description = "Access key  that is created by module"

  value = yandex_iam_service_account_static_access_key.route_switcher_sa_s3_keys.access_key
}


output "secret_key" {
  description = "Secret key that is created by module"

  value = yandex_iam_service_account_static_access_key.route_switcher_sa_s3_keys.secret_key
}

output "sa_id" {
  description = "Service account id that is created by module"

  value = yandex_iam_service_account.route_switcher_sa.id
}

output "first_router_address" {
  description = "Healthchecked IP address of the first router"

  value = var.first_router_address
}
output "second_router_address" {
  description = "Healthchecked IP address of the second router"

  value = var.second_router_address
}