

data "yandex_compute_image" "container-optimized-image" {
  family    = "container-optimized-image"
}

data "template_file" "cloud_init" {
  template = "${file("cloud-init.tpl.yaml")}"
  vars =  {

        ssh_key = "${file(var.public_key_path)}"

    }
}

resource "yandex_compute_instance_group" "ig-frontend" {
  name               = "ig-frontend"
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
    network_interface {
      subnet_ids = [yandex_vpc_subnet.frontend-subnet-a.id, yandex_vpc_subnet.frontend-subnet-b.id, yandex_vpc_subnet.frontend-subnet-c.id]
      nat = true
      security_group_ids = [yandex_vpc_security_group.sg-frontend.id]
    }

    metadata = {
      docker-container-declaration = file("docker-declaration.yaml")
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

  load_balancer {
    target_group_name = "frontend-tg"
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.sabind,
  ]
}



resource "yandex_lb_network_load_balancer" "lb-frontend" {
  name = "lb-frontend"

  listener {
    name = "ngnix-listener"
    port = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-frontend.load_balancer.0.target_group_id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80
    }
      }
    }
  }
