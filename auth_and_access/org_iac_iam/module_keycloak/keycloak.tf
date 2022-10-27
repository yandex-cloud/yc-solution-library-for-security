# =====================
# Keycloak VM Resources
# =====================

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

resource "yandex_vpc_network" "default" {
  name = "default-vpc"
  folder_id = var.folder_id
  depends_on = [time_sleep.wait_60_seconds]
}

resource "yandex_vpc_subnet" "vm_subnet" {
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  folder_id = var.folder_id
}


resource "yandex_vpc_address" "kc_addr" {
  name = var.vm_pub_ip_name
  folder_id = var.folder_id

  external_ipv4_address {
    zone_id = yandex_vpc_subnet.vm_subnet.zone
  }
}

resource "yandex_dns_recordset" "kc_dns_rec" {
  zone_id = data.yandex_dns_zone.dns_zone.id
  name    = split(".",var.kc_fqdn).0
  type    = "A"
  ttl     = 300
  data    = ["${yandex_vpc_address.kc_addr.external_ipv4_address[0].address}"]

  depends_on = [
    yandex_vpc_address.kc_addr
  ]
}

resource "yandex_vpc_security_group" "keycloak_sg" {
  name = "keycloak-sg"
  network_id  = yandex_vpc_network.default.id
  folder_id = var.folder_id

  egress {
    description    = "Permit ALL" 
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "https"
    protocol       = "TCP"
    port           = var.kc_port
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_compute_instance" "vm_instance" {
  name = var.vm_name
  hostname = var.vm_name
  zone = yandex_vpc_subnet.vm_subnet.zone
  folder_id = var.folder_id
  resources {
    cores  = 2
    memory = 4
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.vm_image.id
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.vm_subnet.id
    nat = true
    nat_ip_address = yandex_vpc_address.kc_addr.external_ipv4_address[0].address
    security_group_ids = [
      yandex_vpc_security_group.keycloak_sg.id
    ]
  }
  
  metadata = {
    #ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    ssh-keys = "ubuntu:${chomp(tls_private_key.ssh.public_key_openssh)}"
  }

  # KC provisioning data
  provisioner "file" {
    destination="kc-data.sh"
    content = <<EOF
    KC_FQDN=${var.kc_fqdn}
    KC_REALM=${var.kc_realm}
    KC_VER=${var.kc_ver}
    KC_PORT=${var.kc_port}
    KC_ADM_USER=${var.kc_adm_user}
    KC_ADM_PASS=${var.kc_adm_pass}
    KC_CERT_PATH=${var.kc_cert_path}
    PG_DB_HOST=${yandex_mdb_postgresql_cluster.pg_cluster.host.0.fqdn}
    PG_DB_NAME=${var.pg_db_name}
    PG_DB_USER=${var.pg_db_user}
    PG_DB_PASS=${var.pg_db_pass}
    KC_CERT_PUB="cert-pub-chain.pem"
    KC_CERT_PRIV="cert-priv-key.pem"
    KC_USERS_FN="kc-users.lst"
    EOF
  }

  # KC provisioning script body
  provisioner "file" {
    source = "${path.module}/kc-setup.sh"
    destination = "kc-setup.sh"
  }

  # KC LE certificate (public keys chain )
  provisioner "file" {
    source = "${path.module}/${var.le_cert_pub_key}"
    destination = "cert-pub-chain.pem"
  }

  # KC LE certificate (private key)
  provisioner "file" {
    source = "${path.module}/${var.le_cert_priv_key}"
    destination = "cert-priv-key.pem"
  }

  # KC User accounts file
  provisioner "file" {
    source = "${path.module}/${var.kc_user_file}"
    destination = "kc-users.lst"
  }

  # KC realm configuration for the import
  provisioner "file" {
    destination = "realm.json"
    content = templatefile("${path.module}/realm.json", {
      realm_name = "${var.kc_realm}"
      federation_id = "${yandex_organizationmanager_saml_federation.federation.id}"
    })
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    #private_key = "${file("~/.ssh/id_rsa")}"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    host = yandex_vpc_address.kc_addr.external_ipv4_address[0].address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash kc-setup.sh"
    ]
  }


}

# Работаем с ssh ключем
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "pt_key.pem"
  file_permission = "0600"
}
