resource "helm_release" "falco" {
  depends_on = [
    helm_release.policy_repoter
  ]
  name       = "falco"
  chart      = "falco"
  repository = "https://falcosecurity.github.io/charts"
  namespace = "falco"

  create_namespace = true
  values = [
    "${file("${path.module}/templates/falco-base.yaml")}"
  ]

  set {
    name  = "fakeEventGenerator.enabled"
    value = var.fakeeventgenerator_enabled
  }

  set {
    name  = "ebpf.enabled"
    value = "true"
  }
}

resource "helm_release" "falcosidekick" {
  depends_on = [
    helm_release.falco
  ]
  name       = "falcosidekick"
  chart      = "falcosidekick"
  repository = "https://falcosecurity.github.io/charts"
  namespace = "falco"
  values = [
    "${file("${path.module}/templates/falcosidekick-base.yaml")}"
  ]



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

  


