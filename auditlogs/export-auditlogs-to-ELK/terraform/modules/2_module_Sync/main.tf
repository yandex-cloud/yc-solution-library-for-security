//Импортим sa
data "yandex_iam_service_account" "bucket_sa" {
  service_account_id = var.sa_id
}

//Объявляем image
data "yandex_compute_image" "img_lin" {
  family = "ubuntu-2004-lts"
}

//Создаем static key
resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = data.yandex_iam_service_account.bucket_sa.id
  description        = "static access key for object storage"
}

//Работаем с ssh ключем
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "pt_key.pem"
  file_permission = "0600"
}

data "template_file" "cloud_init_lin" {
  template = file("../modules/2_module_Sync//cloud-init_lin.tpl.yaml")
   vars =  {
        ssh_key = "${chomp(tls_private_key.ssh.public_key_openssh)}"
    }
}

//Создаем docker-declaration
data "template_file" "docker-declaration" {
  template = file("../modules/2_module_Sync/docker-declaration.yaml")
    vars =  {
        ELASTIC_SERVER = "${var.elk_address}:9200"
        KIBANA_SERVER = "${var.elk_address}"
        ELASTIC_AUTH_USER = "admin"
        ELASTIC_AUTH_PW = "${var.elk_credentials}"
        ELASTIC_INDEX_NAME = "audit-trails-index"
        S3_KEY = "${yandex_iam_service_account_static_access_key.sa_static_key.access_key}"
        S3_SECRET = "${yandex_iam_service_account_static_access_key.sa_static_key.secret_key}"
        S3_BUCKET = "${var.bucket_name}"
        S3_FOLDER = "${var.bucket_folder}"
        SLEEP_TIME = "300"
    }
}


//Развертывание Container-optimised image
data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "instance-based-on-coi" {
  name        = "elk-sync"
  hostname    = "elk-sync"
  zone        = "ru-central1-a"
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      type     = "network-ssd"
      size     = 100
    }
  }
  network_interface {
    subnet_id  = var.coi_subnet_id
    #не забыть включить NAT для subnet, где COI 
  }

  resources {
    cores = 4
    memory = 4
  }
  metadata = {
  user-data = "${data.template_file.cloud_init_lin.rendered}"
  docker-container-declaration = "${data.template_file.docker-declaration.rendered}"
}
}