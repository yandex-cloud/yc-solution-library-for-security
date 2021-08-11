data "yandex_iam_service_account" "bucket_sa" {
  service_account_id = var.log_bucket_service_account_id
}



data "yandex_kubernetes_cluster" "my_cluster" {
  folder_id = var.folder_id
  name = var.cluster_name
}

data "yandex_resourcemanager_folder" "my_folder" { 
  folder_id =  var.folder_id
}

resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = data.yandex_iam_service_account.bucket_sa.id
  description        = "static access key for object storage"
}

data "yandex_client_config" "client" {}

provider "helm" {
  kubernetes {
    host     = data.yandex_kubernetes_cluster.my_cluster.master.0.external_v4_endpoint
    cluster_ca_certificate = data.yandex_kubernetes_cluster.my_cluster.master.0.cluster_ca_certificate
    token                  = data.yandex_client_config.client.iam_token

  }
}