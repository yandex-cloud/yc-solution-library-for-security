
resource "yandex_compute_instance" "instance" {
  count              = var.instance_count
  name               = "${var.instance_name}-${format(var.count_format, var.count_offset + count.index + 1)}"
  platform_id        = var.instance_type
  hostname           = "${var.instance_name}-${format(var.count_format, var.count_offset + count.index + 1)}"
  zone               = var.az
  service_account_id = var.service_account_id
  resources {
    cores         = var.cores
    core_fraction = var.core_fraction
    memory        = var.memory
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      type     = var.boot_disk
      size     = var.disk_size
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = var.use_nat
  }
  metadata                  = var.vm_metadata
  allow_stopping_for_update = true
  labels                    = var.labels
}
