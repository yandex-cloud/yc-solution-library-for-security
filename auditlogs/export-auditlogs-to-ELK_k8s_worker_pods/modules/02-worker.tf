locals {
  common_values_yaml = {
    server = {
      image = "${var.worker_docker_image}"
      envVars = {
        elastic = {
          authUser     = "${var.elastic_user}"
          server       = "${var.elastic_server}:9200"
          passEncr     = "${yandex_kms_secret_ciphertext.encrypted_pass.ciphertext}"
          kibanaServer = "${var.elastic_server}"
        }
        sleepTime = "300"
        yandex = {
          cloud = {
            id = "${var.cloud_id}"
          }
          cluster = {
            id = "${data.yandex_kubernetes_cluster.my_cluster.id}"
          }
          folder = {
            id = "${var.folder_id}"
          }
          kms = {
            key = {
              id = "${yandex_kms_symmetric_key.kms-key.id}"
            }
          }
          s3 = {
            bucket = {
              name       = "${var.log_bucket_name}"
              keyEncr    = "${yandex_kms_secret_ciphertext.encrypted_s3_key.ciphertext}"
              secretEncr = "${yandex_kms_secret_ciphertext.encrypted_s3_secret.ciphertext}"
            }
          }
          serviceAccount = {
            id = "${yandex_iam_service_account.sa-writer.id}"
            authKey = {
              id      = "${yandex_iam_service_account_key.sa-auth-key.id}"
              privPem = "${yandex_iam_service_account_key.sa-auth-key.private_key}"
            }
          }
        }
      }
    }
  }
  auditlog_values_yaml = {
    server = {
      replicas = "${var.auditlog_worker_replicas_count}"
      envVars = {
        logPrefix = {
          audit = "AUDIT/"
        }
        yandex = {
          messageQueue = {
            url = "${yandex_message_queue.log_queue_for_auditlog[0].id}"
          }
        }
      }
    }
  }
  falco_values_yaml = {
    server = {
      replicas = "${var.falco_worker_replicas_count}"
      envVars = {
        logPrefix = {
          falco = "FALCO/"
        }
        yandex = {
          messageQueue = {
            url = "${yandex_message_queue.log_queue_for_falco[0].id}"
          }
        }
      }
    }
  }
  kyverno_values_yaml = {
    server = {
      replicas = "${var.kyverno_worker_replicas_count}"
      envVars = {
        logPrefix = {
          kyverno = "KYVERNO/"
        }
        yandex = {
          messageQueue = {
            url = "${yandex_message_queue.log_queue_for_kyverno[0].id}"
          }
        }
      }
    }
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
    "serviceAccount:${yandex_iam_service_account.sa-writer.id}",
  ]
}

resource "yandex_kms_secret_ciphertext" "encrypted_pass" {
  key_id    = yandex_kms_symmetric_key.kms-key.id
  plaintext = var.elastic_pw
}

resource "yandex_kms_secret_ciphertext" "encrypted_s3_key" {
  key_id    = yandex_kms_symmetric_key.kms-key.id
  plaintext = yandex_iam_service_account_static_access_key.sa-writer-keys.access_key
}

resource "yandex_kms_secret_ciphertext" "encrypted_s3_secret" {
  key_id    = yandex_kms_symmetric_key.kms-key.id
  plaintext = yandex_iam_service_account_static_access_key.sa-writer-keys.secret_key
}

resource "helm_release" "auditlog_worker" {
  name             = var.auditlog_worker_chart_name
  namespace        = var.auditlog_worker_namespace
  create_namespace = var.create_namespace
  chart            = "${path.module}/chart"
  values           = [file("${path.module}/chart/values.yaml"), yamlencode(local.common_values_yaml), yamlencode(local.auditlog_values_yaml), file("${path.module}/templates/auditlog-worker-limits.yaml"), var.value]

  dynamic "set" {
    for_each = var.set
    content {
      name  = set.key
      value = set.value
    }
  }
  dynamic "set_sensitive" {
    for_each = var.set_sensitive
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }
}

resource "helm_release" "falco_worker" {
  name             = var.falco_worker_chart_name
  namespace        = var.falco_worker_namespace
  create_namespace = var.create_namespace
  chart            = "${path.module}/chart"
  values           = [file("${path.module}/chart/values.yaml"), yamlencode(local.common_values_yaml), yamlencode(local.falco_values_yaml), file("${path.module}/templates/falco-worker-limits.yaml"), var.value]

  dynamic "set" {
    for_each = var.set
    content {
      name  = set.key
      value = set.value
    }
  }
  dynamic "set_sensitive" {
    for_each = var.set_sensitive
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }
}

resource "helm_release" "kyverno_worker" {
  count            = var.kyverno_enabled ? 1 : 0
  name             = var.kyverno_worker_chart_name
  namespace        = var.kyverno_worker_namespace
  create_namespace = var.create_namespace
  chart            = "${path.module}/chart"
  values           = [file("${path.module}/chart/values.yaml"), yamlencode(local.common_values_yaml), yamlencode(local.kyverno_values_yaml), file("${path.module}/templates/kyverno-worker-limits.yaml"), var.value]

  dynamic "set" {
    for_each = var.set
    content {
      name  = set.key
      value = set.value
    }
  }
  dynamic "set_sensitive" {
    for_each = var.set_sensitive
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }
}
