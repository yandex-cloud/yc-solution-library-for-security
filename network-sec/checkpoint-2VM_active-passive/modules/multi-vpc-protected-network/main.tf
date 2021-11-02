resource "yandex_resourcemanager_folder_iam_member" "route_switcher_sa_roles" {
  count     = length(var.route_switcher_sa_roles)
  folder_id = var.folder_id

  role   = var.route_switcher_sa_roles[count.index]
  member = "serviceAccount:${var.sa_id}"
}




resource "yandex_message_queue" "route_switcher_queue" {
  depends_on = [
    yandex_resourcemanager_folder_iam_member.route_switcher_sa_roles
  ]
  
  access_key = var.access_key
  secret_key = var.secret_key
  name                        = "route-switcher-queue-${var.vpc_id}"
  visibility_timeout_seconds  = 600
  receive_wait_time_seconds   = 20
  message_retention_seconds   = 1209600
  
}

resource "yandex_storage_object" "route_switcher_config" {
  depends_on = [
    yandex_message_queue.route_switcher_queue
  ]
  bucket     = var.bucket_id
  access_key = var.access_key
  secret_key = var.secret_key
  key        = "config-${var.vpc_id}.yaml"
  content = templatefile("${path.module}/templates/route.switcher.tpl.yaml",
    {
      load_balancer_id      = var.load_balancer_id
      target_group_id       = var.target_group_id
      first_router_address  = var.first_router_address
      first_az_rt           = var.first_az_rt
      first_az_subnet_list  = var.first_az_subnet_list
      second_router_address = var.second_router_address
      second_az_rt          = var.second_az_rt
      second_az_subnet_list = var.second_az_subnet_list
    }
  )
}

