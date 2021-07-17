data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}



resource "yandex_compute_instance" "instance-based-on-coi" {
  count = 2
  name        = "app-${element(var.network_names, count.index)}"
  zone        = element(var.zones, count.index)
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.app-subnet[0].id
    nat = false
    #security_group_ids = [yandex_vpc_security_group.sg-dvwa.id]
  }
  resources {
    cores = 2
    memory = 4
  }
  metadata = {
    docker-container-declaration = file("declaration.yaml")
  }
}