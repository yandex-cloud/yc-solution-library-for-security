# Сервисная учетная запись
data "yandex_iam_service_account" "bucket_sa" {
  service_account_id = var.sa_id
}

# Создаем static key
resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = data.yandex_iam_service_account.bucket_sa.id
  description        = "static access key for object storage"
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

# Развертывание Container-Optimised Image
data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "instance-based-on-coi" {
  name                = "elk-sync"
  hostname            = "elk-sync"
  zone                = "ru-central1-a"
  service_account_id  = data.yandex_iam_service_account.bucket_sa.id
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      type     = "network-ssd"
      size     = 100
    }
  }

  network_interface {
    subnet_id  = var.coi_subnet_id # Не забудьте включить NAT для подсети, где будет размещен COI! 
  }

  resources {
    cores   = 4
    memory  = 4
  }

  metadata  = {
    user-data = templatefile("../modules/yc-elastic-trail/cloud-init_lin.tpl.yaml", 
    { 
     ssh_key = "${chomp(tls_private_key.ssh.public_key_openssh)}"
    } 
    )
    docker-container-declaration = templatefile("../modules/yc-elastic-trail/docker-declaration.yaml", 
    {
     ELASTIC_SERVER      = "${var.elk_address}:9200"
     KIBANA_SERVER       = "${var.elk_address}"
     ELASTIC_AUTH_USER   = "admin"
     ELASTIC_INDEX_NAME  = "audit-trails-index"
     S3_BUCKET           = "${var.bucket_name}"
     S3_FOLDER           = "${var.bucket_folder}"
     SLEEP_TIME          = "300"
     ELK_PASS_ENCR       = "${yandex_kms_secret_ciphertext.encrypted_pass.ciphertext}"
     S3_KEY_ENCR         = "${yandex_kms_secret_ciphertext.encrypted_s3_key.ciphertext}"
     S3_SECRET_ENCR      = "${yandex_kms_secret_ciphertext.encrypted_s3_secret.ciphertext}"
     KMS_KEY_ID          = "${yandex_kms_symmetric_key.key-elk.id}"
    }
    )
  }
}

# Создание KMS ключа
resource "yandex_kms_symmetric_key" "key-elk" {
  name              = "key-elk"
  description       = "description for key"
  default_algorithm = "AES_128"
}

# Назначение роли на sa на расшифровку ключа
resource "yandex_resourcemanager_folder_iam_binding" "binding" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${data.yandex_iam_service_account.bucket_sa.id}",
  ]
}

resource "yandex_kms_secret_ciphertext" "encrypted_pass" {
  key_id      = yandex_kms_symmetric_key.key-elk.id
  plaintext   = var.elk_credentials
}

resource "yandex_kms_secret_ciphertext" "encrypted_s3_key" {
  key_id      = yandex_kms_symmetric_key.key-elk.id
  plaintext   = yandex_iam_service_account_static_access_key.sa_static_key.access_key
}

resource "yandex_kms_secret_ciphertext" "encrypted_s3_secret" {
  key_id      = yandex_kms_symmetric_key.key-elk.id
  plaintext   = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
}
