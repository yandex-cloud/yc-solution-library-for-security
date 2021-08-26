
//----------------------Подготовка тестовой инфраструктуры-----------------------------------
//Генерация random-string для имени bucket---------------------------------------------------------
resource "random_string" "random" {
  length           = 8
  special          = false
  upper            = false 
}
//Создание сети
resource "yandex_vpc_network" "vpc-elk" {
  name = "vpc-enc"
}
//Создание подсетей
resource "yandex_vpc_subnet" "elk-subnet" {

  name           = "vm-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-enc.id
  v4_cidr_blocks = [element(var.app_cidrs, count.index)]
}
//Создание sa storage admin 
resource "yandex_iam_service_account" "sa-bucket-creator" {
  name        = "sa-bucket-creator-${random_string.random.result}"
  folder_id = var.folder_id
}
//Создание стат ключа
resource "yandex_iam_service_account_static_access_key" "sa-bucket-creator-sk" {
  service_account_id = yandex_iam_service_account.sa-bucket-creator.id
}
//Назначение прав для создания бакета
resource "yandex_resourcemanager_folder_iam_binding" "storage_admin" {
  folder_id = var.folder_id

  role = "storage.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-creator.id}",
  ]
}

//Создание S3 bucket для
resource "yandex_storage_bucket" "trail-bucket" {
  bucket = "bucket-for-encryption-${random_string.random.result}"

  access_key = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.secret_key
}

//Создание sa storage editor для работы от VM с Bucket 
resource "yandex_iam_service_account" "sa-bucket-editor" {
  name        = "sa-bucket-editor-${random_string.random.result}"
  folder_id = var.folder_id
}

//Назначение прав для изменения бакета
resource "yandex_resourcemanager_folder_iam_binding" "storage_editor" {
  folder_id = var.folder_id

  role = "storage.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-editor.id}",
  ]
}

//Создание стат ключа editor
resource "yandex_iam_service_account_static_access_key" "sa-bucket-editor_stat" {
  service_account_id = yandex_iam_service_account.sa-bucket-editor.id
}

//Работа с ssh ключем
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
  template = file("./cloud-init_lin.tpl.yaml")
   vars =  {
        ssh_key = "${chomp(tls_private_key.ssh.public_key_openssh)}"
        aws_key = "${yandex_iam_service_account_static_access_key.sa-bucket-editor_stat.access_key}"
        aws_sec = "${secret_key = yandex_iam_service_account_static_access_key.sa-bucket-editor_stat.secret_key}"
    }
}



//Развертывание ВМ
data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "instance-based-on-coi" {
  name        = "elk-sync"
  hostname    = "elk-sync"
  zone        = "ru-central1-a"
  service_account_id = data.yandex_iam_service_account.bucket_sa.id
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



//Создание KMS ключа
resource "yandex_kms_symmetric_key" "key-elk" {
  name              = "key-elk"
  description       = "description for key"
  default_algorithm = "AES_128"
}

//Назначение роли на sa на расшифровку ключа
resource "yandex_resourcemanager_folder_iam_binding" "binding" {
  folder_id = var.folder_id

  role = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${data.yandex_iam_service_account.sa-bucket-editor.id}",
  ]
}