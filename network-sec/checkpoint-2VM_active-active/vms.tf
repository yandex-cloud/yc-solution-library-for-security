//Create passwords (change this after first login)
resource "random_password" "pass-sms" {
  count   = 1
  length  = 10
  special = false
}

resource "random_password" "pass-sic" {
  count   = 1
  length  = 13
  special = false
}

resource "random_password" "pass-win" {
  count   = 1
  length  = 20
  special = true
}

//Create ssh keys
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "pt_key.pem"
  file_permission = "0600"
}

//Rnder cloud_init_files
data "template_file" "cloud_init_sms" {
  template = file("./check-init-sms.yaml")
   vars =  {
        ssh_key = "${chomp(tls_private_key.ssh.public_key_openssh)}"
        pass = "${random_password.pass-sms[0].result}"
    }
}

data "template_file" "cloud_init_gw-a" {
  template = file("./check-init_gw-a.yaml")
   vars =  {
        ssh_key = "${chomp(tls_private_key.ssh.public_key_openssh)}"
        pass_sic = "${random_password.pass-sic[0].result}"
        dst-1 =  "${replace(var.subnet-b_vpc_1, "1.0/24", "0.0/16")}"
        next-hop-1 = "${cidrhost(var.subnet-a_vpc_3, 1)}"
    }
}

data "template_file" "cloud_init_gw-b" {
  template = file("./check-init_gw-b.yaml")
   vars =  {
        ssh_key = "${chomp(tls_private_key.ssh.public_key_openssh)}"
        pass_sic = "${random_password.pass-sic[0].result}"
        dst-1 =  "${replace(var.subnet-a_vpc_1, "1.0/24", "0.0/16")}"
        next-hop-1 = "${cidrhost(var.subnet-b_vpc_3, 1)}"
        dst-2 =  var.subnet-a_vpc_4
        next-hop-2 = "${cidrhost(var.subnet-b_vpc_4, 1)}"
    }
}

data "template_file" "cloud_init_win" {
  template = file("./cloud-init_win.tpl.yaml")
  vars =  {
        pass-win = "${random_password.pass-win[0].result}"
    }
}


//Create checkpoint-a(FW-A)
resource "yandex_compute_instance" "fw-a" {
  folder_id = yandex_resourcemanager_folder.folder4.id
  name        = "fw-a"
  zone        = "ru-central1-a"
  hostname    = "fw-a"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8lv3k0bcm4a5v49mff"
      type     = "network-ssd"
      size     = 120
    }
    }
  network_interface {
    //mgmt-int
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_4.id 
    ip_address = "${cidrhost(var.subnet-a_vpc_4, 10)}"
    nat = false
}
  
  network_interface {
    //transit-int
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_3.id
    ip_address = "${cidrhost(var.subnet-a_vpc_3, 10)}"
    nat = true
}

  network_interface {
    //servers-int
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_1.id
    ip_address = "${cidrhost(var.subnet-a_vpc_1, 10)}"
    nat = false
}

  network_interface {
    //database-int
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_2.id
    ip_address = "${cidrhost(var.subnet-a_vpc_2, 10)}"
    nat = false
}

  network_interface {
    //vpc5-int
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_5.id
    ip_address = "${cidrhost(var.subnet-a_vpc_5, 10)}"
    nat = false
}

  network_interface {
    //vpc6-int
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_6.id
    ip_address = "${cidrhost(var.subnet-a_vpc_6, 10)}"
    nat = false
}

  network_interface {
    //vpc7-int
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_7.id
    ip_address = "${cidrhost(var.subnet-a_vpc_7, 10)}"
    nat = false
}

  network_interface {
    //vpc8-int
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_8.id
    ip_address = "${cidrhost(var.subnet-a_vpc_8, 10)}"
    nat = false
}

metadata = {
  user-data = "${data.template_file.cloud_init_gw-a.rendered}"
  serial-port-enable = 1
}
}

//------------------------------------------------------------------------------------------------

//Create checkpoint-a(FW-B)
resource "yandex_compute_instance" "fw-b" {
  folder_id = yandex_resourcemanager_folder.folder4.id
  name        = "fw-b"
  zone        = "ru-central1-b"
  hostname    = "fw-b"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8lv3k0bcm4a5v49mff"
      type     = "network-ssd"
      size     = 120
    }
    }
  network_interface {
    //mgmt-int
    subnet_id  = yandex_vpc_subnet.subnet-b_vpc_4.id 
    ip_address = "${cidrhost(var.subnet-b_vpc_4, 10)}"
    nat = false
}
  
  network_interface {
    //transit-int
    subnet_id  = yandex_vpc_subnet.subnet-b_vpc_3.id
    ip_address = "${cidrhost(var.subnet-b_vpc_3, 10)}"
    nat = true
}

  network_interface {
    //servers-int
    subnet_id  = yandex_vpc_subnet.subnet-b_vpc_1.id
    ip_address = "${cidrhost(var.subnet-b_vpc_1, 10)}"
    nat = false
}

  network_interface {
    //database-int
    subnet_id  = yandex_vpc_subnet.subnet-b_vpc_2.id
    ip_address = "${cidrhost(var.subnet-b_vpc_2, 10)}"
    nat = false
}

  network_interface {
    //vpc5-int
    subnet_id  = yandex_vpc_subnet.subnet-b_vpc_5.id
    ip_address = "${cidrhost(var.subnet-b_vpc_5, 10)}"
    nat = false
}

  network_interface {
    //vpc6-int
    subnet_id  = yandex_vpc_subnet.subnet-b_vpc_6.id
    ip_address = "${cidrhost(var.subnet-b_vpc_6, 10)}"
    nat = false
}

  network_interface {
    //vpc7-int
    subnet_id  = yandex_vpc_subnet.subnet-b_vpc_7.id
    ip_address = "${cidrhost(var.subnet-b_vpc_7, 10)}"
    nat = false
}

  network_interface {
    //vpc8-int
    subnet_id  = yandex_vpc_subnet.subnet-b_vpc_8.id
    ip_address = "${cidrhost(var.subnet-b_vpc_8, 10)}"
    nat = false
}

metadata = {
  user-data = "${data.template_file.cloud_init_gw-b.rendered}"
  serial-port-enable = 1
}
}

//-------------------------------------------

//Createтывание checkpoint management server
resource "yandex_compute_instance" "mgmt-server" {
  folder_id = yandex_resourcemanager_folder.folder4.id
  name        = "mgmt-server"
  zone        = "ru-central1-a"
  hostname    = "mgmt-server"
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8hcf4gjv3adselqajo"
      type     = "network-ssd"
      size     = 120
    }
    }


  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_4.id
    ip_address = "${cidrhost(var.subnet-a_vpc_4, 100)}"
    nat = false
    #security_group_ids = [yandex_vpc_security_group.ptaf-sg.id]
}

metadata = {
  user-data = "${data.template_file.cloud_init_sms.rendered}"
  serial-port-enable = 1
}
}

//Create win-pc
resource "yandex_compute_instance" "win-check" {
  folder_id = yandex_resourcemanager_folder.folder4.id
  name        = "win-check"
  hostname    = "win-check"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"
  

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vbpg8aq7gmf72a7qh"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-a_vpc_4.id
    ip_address = "${cidrhost(var.subnet-a_vpc_4, 101)}"
    nat                = true
  }

  metadata = {
    user-data = "${data.template_file.cloud_init_win.rendered}"
  }
}



output "a-external_ip_address_of_win-check-vm" {
  value = yandex_compute_instance.win-check.network_interface.0.nat_ip_address
}

output "b-password-for-win-check" {
  value = "${random_password.pass-win[0].result}"
  sensitive = true
}


output "c-ip_address_mgmt-server" {
  value = yandex_compute_instance.mgmt-server.network_interface.0.ip_address
}

output "d-ui_console_mgmt-server_password" {
  value = "admin"
}

output "e-gui_console_mgmt-server_password" {
  value = "${random_password.pass-sms[0].result}"
  sensitive = true
}

output "f-sic-password" {
  value = "${random_password.pass-sic[0].result}"
  sensitive = true
}

output "g-ip_address_fw-a" {
  value = yandex_compute_instance.fw-a.network_interface.0.ip_address
}


output "h-ip_address_fw-b" {
  value = yandex_compute_instance.fw-b.network_interface.0.ip_address
}

output "i-path_for_private_ssh_key" {
  value = "./pt_key.pem"
}






