resource "helm_release" "kyverno-policies" {
    depends_on = [
    helm_release.kyverno
  ]
  name       = "kyverno-policies"
  chart      = "kyverno-policies"
  repository = "https://kyverno.github.io/kyverno/"
  namespace = "kyverno"

  

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
  
  name       = "kyverno"
  chart      = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  namespace = "kyverno"
  create_namespace = true

}
 resource "helm_release" "policy_repoter" {
  depends_on = [
    helm_release.kyverno
  ]
  name       = "policy-reporter"
  chart      = "policy-reporter"
  repository = "https://kyverno.github.io/policy-reporter"
  namespace = "kyverno"



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
    value = "KYVERNO/${data.yandex_resourcemanager_folder.my_folder.cloud_id}/${var.folder_id}/${data.yandex_kubernetes_cluster.my_cluster.id}"
  }


}

  


