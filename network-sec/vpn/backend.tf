
resource "yandex_compute_instance_group" "ig-backend" {
  name               = "ig-backend"
  service_account_id = yandex_iam_service_account.ig_sa.id
  folder_id = var.folder_id

  instance_template {
    platform_id = "standard-v2"
    resources {
      cores  = 4
      memory = 8

    }
    service_account_id = yandex_iam_service_account.ig_sa.id
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.container-optimized-image.id
        size     = 13
      }
    }
    secondary_disk {
      mode = "READ_WRITE"
      device_name = "coi-data"
      initialize_params {
        size     = 13
        type = "network-ssd"
      }
    }
    network_interface {
      subnet_ids = [yandex_vpc_subnet.backend-subnet-a.id, yandex_vpc_subnet.backend-subnet-b.id, yandex_vpc_subnet.backend-subnet-c.id]
      nat=true
      security_group_ids = [yandex_vpc_security_group.sg-backend.id]
    }

    metadata = {
      docker-compose = file("docker-compose.yaml")
      user-data = "${data.template_file.cloud_init.rendered}"
      serial-port-enable = 1
    }
  }

  scale_policy {
   fixed_scale {
     size = 3
   }
 }

 allocation_policy {
   zones = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
 }

 deploy_policy {
   max_unavailable = 3
   max_creating    = 3
   max_expansion   = 3
   max_deleting    = 3
 }


  depends_on = [
    yandex_resourcemanager_folder_iam_binding.sabind,
  ]
}
