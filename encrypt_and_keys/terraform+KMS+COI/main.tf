
//----------------------Подготовка тестовой инфраструктуры-----------------------------------
//Создание сети
resource "yandex_vpc_network" "vpc-test" {
  name = "vpc-test"
}
//Создание подсетей
resource "yandex_vpc_subnet" "test-subnet" {
  folder_id = var.folder_id

  name           = "app-secret-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-test.id
  v4_cidr_blocks = ["192.168.97.0/24"]
}
//Создание sa 
resource "yandex_iam_service_account" "sa-test-secret" {
  name        = "sa-test-secret"
  folder_id = var.folder_id
}

//Создание стат ключа
resource "yandex_iam_service_account_static_access_key" "sa-sk" {
  service_account_id = yandex_iam_service_account.sa-test-secret.id
}

//Создаем docker-declaration
data "template_file" "docker-declaration" {
  template = file("./docker-declaration.yaml")
    vars =  {
        S3_KEY_ENCR = "${yandex_kms_secret_ciphertext.encrypted_s3_key.ciphertext}"
        S3_SECRET_ENCR = "${yandex_kms_secret_ciphertext.encrypted_s3_secret.ciphertext}"
        KMS_KEY_ID = "${yandex_kms_symmetric_key.key-elk.id}"
        SLEEP_TIME = "300"
    }
}

//Развертывание Container-optimised image
data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "instance-based-on-coi" {
  name        = "kms-test"
  hostname    = "kms-test"
  zone        = "ru-central1-a"
  service_account_id = yandex_iam_service_account.sa-test-secret.id
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      type     = "network-ssd"
      size     = 100
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.test-subnet.id
    #не забыть включить NAT для subnet, где COI 
    nat                = true
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
    "serviceAccount:${yandex_iam_service_account.sa-test-secret.id}",
  ]
}

resource "yandex_kms_secret_ciphertext" "encrypted_s3_key" {
  key_id      = yandex_kms_symmetric_key.key-elk.id
  plaintext   = yandex_iam_service_account_static_access_key.sa-sk.access_key
}

resource "yandex_kms_secret_ciphertext" "encrypted_s3_secret" {
  key_id      = yandex_kms_symmetric_key.key-elk.id
  plaintext   = yandex_iam_service_account_static_access_key.sa-sk.secret_key
}