resource "helm_release" "falco" {
  name       = "falco"
  chart      = "${path.module}/charts/falco"
  namespace = "falco"
  create_namespace = true

  set {
    name  = "fakeEventGenerator.enabled"
    value = "true"
  }
  set {
    name  = "ebpf.enabled"
    value = "true"
    }


}

resource "helm_release" "falcosidekick" {
  depends_on = [helm_release.falco]
  name       = "falcosidekick"
  repository = "https://falcosecurity.github.io/charts"
  chart = "falcosidekick"
  namespace = "falco"

  set {
  
    name  = "config.yandex.accesskeyid"
    value = yandex_iam_service_account_static_access_key.sa_static_key.access_key
  }
  set {
  
    name  = "config.yandex.secretaccesskey"
    value = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
  }

  set {
  
    name  = "config.yandex.s3.bucket"
    value = var.log_bucket_name
  }

  set {
  
    name  = "config.yandex.s3.prefix"
    value = "FALCO/${data.yandex_resourcemanager_folder.my_folder.cloud_id}/${var.folder_id}/${data.yandex_kubernetes_cluster.my_cluster.id}"
  }

}
