data "yandex_compute_image" "my_image" {
  family = "ubuntu-1804-lts"
}

data "template_file" "ipsec_init" {
  template = "${file("ipsec-init.tpl.yaml")}"
  vars =  {

        ssh_key = "${file(var.public_key_path)}"
        vpn_addr = yandex_vpc_address.vpnaddr.external_ipv4_address.0.address
        remote_addr = yandex_vpc_address.remoteaddr.external_ipv4_address.0.address
        ipsec_pass = var.ipsec_password

    }
}

resource "yandex_vpc_address" "vpnaddr" {
  name = "vpnaddr"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_compute_instance" "cloud-vpn-gate" {
  zone        = "ru-central1-a"
  name        = "cloud-vpn-gate"
  hostname    = "cloud-vpn-gate"
  platform_id = "standard-v2"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_vpn.id
      type     = "network-ssd"
      size     = 13
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.vpn-subnet-a.id
    ip_address = "10.10.5.5"
    nat = true
    nat_ip_address = yandex_vpc_address.vpnaddr.external_ipv4_address.0.address
    security_group_ids = [yandex_vpc_security_group.sg-ipsec.id]
}

metadata = {
  user-data = "${data.template_file.ipsec_init.rendered}"
  serial-port-enable = 1
}
}
