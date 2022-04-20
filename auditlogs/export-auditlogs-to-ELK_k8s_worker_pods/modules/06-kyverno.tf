resource "helm_release" "kyverno-policies" {
  depends_on = [
    helm_release.kyverno
  ]
  count      = var.kyverno_enabled ? 1 : 0
  name       = "kyverno-policies"
  chart      = "kyverno-policies"
  version    = var.kyverno_policies_version
  repository = "https://kyverno.github.io/kyverno/"
  namespace  = var.kyverno_helm_namespace

  set {
    name  = "podSecurityStandard"
    value = var.podSecurityStandard
  }

  set {
    name  = "validationFailureAction"
    value = var.validationFailureAction
  }

}

resource "helm_release" "kyverno" {
  count            = var.kyverno_enabled ? 1 : 0
  name             = "kyverno"
  chart            = "kyverno"
  version          = var.kyverno_version
  repository       = "https://kyverno.github.io/kyverno/"
  namespace        = var.kyverno_helm_namespace
  create_namespace = var.create_namespace
  values           = ["${file("${path.module}/templates/kyverno-base.yaml")}"]
}

resource "helm_release" "policy_reporter" {
  depends_on = [
    helm_release.kyverno
  ]
  count      = var.kyverno_enabled ? 1 : 0
  name       = "policy-reporter"
  chart      = "policy-reporter"
  version    = var.policy_reporter_version
  repository = "https://kyverno.github.io/policy-reporter"
  namespace  = var.kyverno_helm_namespace
  values     = ["${file("${path.module}/templates/policy-reporter-base.yaml")}"]
  set {
    name  = "target.s3.accessKeyID"
    value = yandex_iam_service_account_static_access_key.sa_static_key.access_key
  }

  set {
    name  = "target.s3.secretAccessKey"
    value = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
  }

  set {
    name  = "target.s3.bucket"
    value = var.log_bucket_name
  }

  set {
    name  = "target.s3.prefix"
    value = "KYVERNO/${data.yandex_kubernetes_cluster.my_cluster.name}"
  }

  set {
    name  = "target.s3.region"
    value = var.region_name
  }

  set {
    name  = "target.s3.endpoint"
    value = "https://storage.yandexcloud.net"
  }
}
