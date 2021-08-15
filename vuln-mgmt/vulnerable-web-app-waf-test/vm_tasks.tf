data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "instance-based-on-coi" {
  name        = "dvwa"
  zone        = "ru-central1-a"
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.dvwa-subnet.id
    nat = true
    nat_ip_address = yandex_vpc_address.dvwa-address.external_ipv4_address.0.address
    security_group_ids = [yandex_vpc_security_group.sg-dvwa.id]
  }
  resources {
    cores = 2
    memory = 4
  }
  metadata = {
    docker-container-declaration = file("declaration.yaml")
    user-data = file("cloud_config.yaml")
  }
}