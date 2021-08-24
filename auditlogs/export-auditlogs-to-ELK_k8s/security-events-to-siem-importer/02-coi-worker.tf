resource "tls_private_key" "ssh" {
    algorithm = "RSA"
    rsa_bits  = "4096"
}

resource "local_file" "private_key" {
    content         = tls_private_key.ssh.private_key_pem
    filename        = "pt_key.pem"
    file_permission = "0600"
}

data "template_file" "cloud_init" {
    template = file("../security-events-to-siem-importer/worker/cloud-init.tpl.yaml")
    vars =  {
        ssh_key = "${chomp(tls_private_key.ssh.public_key_openssh)}"
    }
}

data "template_file" "docker-declaration-auditlog" {
    template = file("../security-events-to-siem-importer/worker/docker-declaration-auditlog.yaml")
    vars =  {
        ELASTIC_AUTH_USER   = "${var.elastic_user}"
        ELASTIC_SERVER      = "${var.elastic_server}:9200"
        ELK_PASS_ENCR       = "${yandex_kms_secret_ciphertext.encrypted_pass.ciphertext}"
        KIBANA_SERVER       = "${var.elastic_server}"
        KMS_KEY_ID          = "${yandex_kms_symmetric_key.kms-key.id}"
        S3_BUCKET           = "${var.log_bucket_name}"
        S3_KEY_ENCR         = "${yandex_kms_secret_ciphertext.encrypted_s3_key.ciphertext}"
        S3_SECRET_ENCR      = "${yandex_kms_secret_ciphertext.encrypted_s3_secret.ciphertext}"
        SLEEP_TIME          = "300"
        AUDIT_LOG_PREFIX    = "AUDIT/"
        YMQ_URL             = "${yandex_message_queue.log_queue_for_auditlog[0].id}"
    }
}

data "template_file" "docker-declaration-falco" {
    template = file("../security-events-to-siem-importer/worker/docker-declaration-falco.yaml")
    vars =  {
        ELASTIC_AUTH_USER   = "${var.elastic_user}"
        ELASTIC_SERVER      = "${var.elastic_server}:9200"
        ELK_PASS_ENCR       = "${yandex_kms_secret_ciphertext.encrypted_pass.ciphertext}"
        KIBANA_SERVER       = "${var.elastic_server}"
        KMS_KEY_ID          = "${yandex_kms_symmetric_key.kms-key.id}"
        S3_BUCKET           = "${var.log_bucket_name}"
        S3_KEY_ENCR         = "${yandex_kms_secret_ciphertext.encrypted_s3_key.ciphertext}"
        S3_SECRET_ENCR      = "${yandex_kms_secret_ciphertext.encrypted_s3_secret.ciphertext}"
        SLEEP_TIME          = "300"
        FALCO_LOG_PREFIX    = "FALCO/"
        YMQ_URL             = "${yandex_message_queue.log_queue_for_falco[0].id}"
    }
}

data "yandex_compute_image" "container-optimized-image" {
    family = "container-optimized-image"
}

resource "yandex_compute_instance" "instance-based-on-coi-auditlog" {
    name        = "k8s-auditlog-siem-worker"
    hostname    = "k8s-auditlog-siem-worker"
    zone        = "ru-central1-a"
    service_account_id = var.service_account_id
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.container-optimized-image.id
            type     = "network-ssd"
            size     = 100
        }
    }
    network_interface {
        subnet_id  = var.coi_subnet_id
        # не забыть включить NAT для subnet, где COI 
    }

    resources {
        cores = 2
        memory = 2
    }
    metadata = {
        user-data                       = "${data.template_file.cloud_init.rendered}"
        docker-container-declaration    = "${data.template_file.docker-declaration-auditlog.rendered}"
    }
}

resource "yandex_compute_instance" "instance-based-on-coi-falco" {
    name        = "k8s-falco-siem-worker"
    hostname    = "k8s-falco-siem-worker"
    zone        = "ru-central1-a"
    service_account_id = var.service_account_id
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.container-optimized-image.id
            type     = "network-ssd"
            size     = 100
        }
    }
    network_interface {
        subnet_id  = var.coi_subnet_id
        # не забыть включить NAT для subnet, где COI 
    }

    resources {
        cores = 2
        memory = 2
    }
    metadata = {
        user-data                       = "${data.template_file.cloud_init.rendered}"
        docker-container-declaration    = "${data.template_file.docker-declaration-falco.rendered}"
    }
}

resource "yandex_kms_symmetric_key" "kms-key" {
    name              = "kms-key-${random_string.project_suffix.result}"
    description       = "Key for secrets encryption"
    default_algorithm = "AES_128"
}

resource "yandex_resourcemanager_folder_iam_binding" "binding" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${var.service_account_id}",
  ]
}

resource "yandex_kms_secret_ciphertext" "encrypted_pass" {
  key_id      = yandex_kms_symmetric_key.kms-key.id
  plaintext   = var.elastic_pw
}

resource "yandex_kms_secret_ciphertext" "encrypted_s3_key" {
  key_id      = yandex_kms_symmetric_key.kms-key.id
  plaintext   = yandex_iam_service_account_static_access_key.sa_static_key.access_key
}

resource "yandex_kms_secret_ciphertext" "encrypted_s3_secret" {
  key_id      = yandex_kms_symmetric_key.kms-key.id
  plaintext   = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
}