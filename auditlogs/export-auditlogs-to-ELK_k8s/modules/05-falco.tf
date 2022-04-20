resource "helm_release" "falco" {
  depends_on       = [helm_release.policy_reporter]
  name             = "falco"
  chart            = "falco"
  version          = var.falco_version
  repository       = "https://falcosecurity.github.io/charts"
  namespace        = var.falco_helm_namespace
  create_namespace = var.create_namespace
  values           = ["${file("${path.module}/templates/falco-base.yaml")}"]

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
  depends_on = [helm_release.falco]
  name       = "falcosidekick"
  chart      = "falcosidekick"
  version    = var.falcosidekick_version
  repository = "https://falcosecurity.github.io/charts"
  namespace  = var.falco_helm_namespace
  values     = ["${file("${path.module}/templates/falcosidekick-base.yaml")}"]

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
    value = "FALCO/${data.yandex_kubernetes_cluster.my_cluster.name}"
  }
}
