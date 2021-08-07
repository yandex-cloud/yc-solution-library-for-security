data "yandex_compute_image" "nat_instance" {
  family = "nat-instance-ubuntu"
}

data "yandex_compute_image" "img_bastion" {
  family = "ubuntu-2004-lts"
}

data "yandex_compute_image" "vm_img" {
  family = "ubuntu-1804-lts"
}
data "template_file" "cloud_init_bastion" {
  template = "${file("cloud-init-bastion.tpl.yaml")}"
  vars =  {

        aws_key = "${module.sa_and_key.aws_key_id}"
        aws_sec = "${module.sa_and_key.aws_secret}"
        ssh_key = "${file(var.public_key_path)}"

    }
}

data "template_file" "cloud_init" {
  template = "${file("cloud-init.tpl.yaml")}"
  vars =  {

        ssh_key = "${file(var.public_key_path)}"

    }
}


resource "yandex_compute_instance" "nat-instance" {
  zone        = "ru-central1-a"
  name        = "nat-instance"
  hostname    = "nat-instance"
  platform_id = "standard-v2"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.nat_instance.id
      type     = "network-ssd"
      size     = 26
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public-subnet.id
    ip_address = "10.0.0.5"
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-inet-acc.id]
}

metadata = {
  user-data = "${data.template_file.cloud_init.rendered}"
  serial-port-enable = 1
}
}

resource "yandex_compute_instance" "vm-ci-cd" {
  zone        = "ru-central1-a"
  name        = "vm-ci-cd"
  hostname    = "vm-ci-cd"
  platform_id = "standard-v2"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_img.id
      type     = "network-ssd"
      size     = 26
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.tools-subnet.id
    ip_address = "10.50.0.5"
    nat = false
    security_group_ids = [yandex_vpc_security_group.sg-ci-cd.id]
}

metadata = {
  user-data = "${data.template_file.cloud_init.rendered}"
  serial-port-enable = 1
}
}

resource "yandex_compute_instance" "bastion" {
  zone        = "ru-central1-a"
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v2"
  service_account_id = "${module.sa_and_key.s3_writer}"
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.img_bastion.id
      type     = "network-ssd"
      size     = 26
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public-subnet.id
    ip_address = "10.0.0.10"
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-bastion.id]
}

metadata = {
  user-data = "${data.template_file.cloud_init_bastion.rendered}"
  serial-port-enable = 1
}
}

resource "yandex_compute_instance" "vm-dev" {
  zone        = "ru-central1-a"
  name        = "vm-dev"
  hostname    = "vm-dev"
  platform_id = "standard-v2"
  folder_id = var.dev_folder_id
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_img.id
      type     = "network-ssd"
      size     = 26
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-dev.id
    ip_address = "10.30.0.5"
    nat = true
    security_group_ids = [yandex_vpc_security_group.sg-dev.id]
}

metadata = {
  user-data = "${data.template_file.cloud_init.rendered}"
  serial-port-enable = 1
}
}

resource "yandex_compute_instance" "app-stage" {
  zone        = "ru-central1-a"
  name        = "app-stage"
  hostname    = "app-stage"
  platform_id = "standard-v2"
  folder_id = var.stage_folder_id
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_img.id
      type     = "network-ssd"
      size     = 26
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-stage.id
    ip_address = "10.20.0.5"
    nat = false
    security_group_ids = [yandex_vpc_security_group.sg-stage.id]
}

metadata = {
  user-data = "${data.template_file.cloud_init.rendered}"
  serial-port-enable = 1
}
}

resource "yandex_compute_instance" "app-prod" {
  zone        = "ru-central1-a"
  name        = "app-prod"
  hostname    = "app-prod"
  platform_id = "standard-v2"
  folder_id = var.prod_folder_id
  resources {
    cores  = 2
    memory = 4
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_img.id
      type     = "network-ssd"
      size     = 26
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-prod.id
    ip_address = "10.10.0.5"
    nat = false
    security_group_ids = [yandex_vpc_security_group.sg-prod.id]
}

metadata = {
  user-data = "${data.template_file.cloud_init.rendered}"
  serial-port-enable = 1
}
}
