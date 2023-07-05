data "yandex_compute_image" "vm_image" {
  image_id = var.image_id
}

data "template_file" "default" {
  template = file("init.ps1")
  vars = {
    secret_id = yandex_lockbox_secret.password_secret.id
  }
}

#Create VM
 
resource "yandex_compute_instance" "windows" {
  name     = var.vm_name
  hostname = var.host_name
  zone     = var.zone
  platform_id = var.platform_id
  service_account_id = yandex_iam_service_account.win-sa.id

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_image.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.win-subnet[0].id
    nat       = var.nat
  }

  metadata = {
    user-data = data.template_file.default.rendered
  }

  depends_on = [
    yandex_kms_symmetric_key.win-key,
    yandex_iam_service_account.win-sa,
    yandex_lockbox_secret.password_secret,
    null_resource.lockbox_secrets_access_binding
  ]
}