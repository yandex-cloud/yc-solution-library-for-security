resource "yandex_lb_target_group" "router_switcher_tg" {
  folder_id = var.folder_id
  name      = "route-switcher-tg"
  region_id = "ru-central1"

  target {
    subnet_id = var.first_router_subnet
    address   = var.first_router_address
  }

  target {
    subnet_id = var.second_router_subnet
    address   = var.second_router_address
  }
}

resource "yandex_lb_network_load_balancer" "router_switcher_lb" {
  folder_id = var.folder_id
  name = "route-switcher-lb"
  type = "internal"

  listener {
    name = "my-listener"
    port = 443
    internal_address_spec {
      subnet_id = var.first_router_subnet
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.router_switcher_tg.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = var.router_check_port
        
      }
    }
  }
}




resource "random_string" "prefix" {
  length  = 10
  upper   = false
  lower   = true
  number  = true
  special = false
}


resource "yandex_iam_service_account" "route_switcher_sa" {
  folder_id = var.folder_id
  name = "route-switcher-sa-${random_string.prefix.result}"
}
resource "yandex_iam_service_account_static_access_key" "route_switcher_sa_s3_keys" {
  service_account_id = yandex_iam_service_account.route_switcher_sa.id
}

resource "yandex_resourcemanager_folder_iam_member" "route_switcher_sa_roles" {
  
  count     = length(var.route_switcher_sa_roles)
  folder_id = var.folder_id

  role   = var.route_switcher_sa_roles[count.index]
  member = "serviceAccount:${yandex_iam_service_account.route_switcher_sa.id}"
}



resource "yandex_storage_bucket" "route_switcher_bucket" {
  depends_on = [yandex_resourcemanager_folder_iam_member.route_switcher_sa_roles]
  bucket     = "route-switcher-${random_string.prefix.result}"
  access_key = yandex_iam_service_account_static_access_key.route_switcher_sa_s3_keys.access_key
  secret_key = yandex_iam_service_account_static_access_key.route_switcher_sa_s3_keys.secret_key
}
