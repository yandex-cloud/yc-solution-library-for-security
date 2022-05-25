data "yandex_iam_service_account" "bucket_sa" {
  depends_on = [yandex_iam_service_account.sa-writer]
  name       = var.service_account_id
}

data "yandex_kubernetes_cluster" "my_cluster" {
  folder_id = var.folder_id
  name      = var.cluster_name
}

data "yandex_resourcemanager_folder" "my_folder" {
  folder_id = var.folder_id
}

resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = data.yandex_iam_service_account.bucket_sa.id
  description        = "static access key for object storage"
}

data "yandex_client_config" "client" {}

provider "helm" {
  kubernetes {
    host     = data.yandex_kubernetes_cluster.my_cluster.master.0.public_ip == true ?   data.yandex_kubernetes_cluster.my_cluster.master.0.external_v4_endpoint : data.yandex_kubernetes_cluster.my_cluster.master.0.internal_v4_endpoint 
    cluster_ca_certificate = data.yandex_kubernetes_cluster.my_cluster.master.0.cluster_ca_certificate
    token                  = data.yandex_client_config.client.iam_token

  }
}
