

data "yandex_kubernetes_cluster" "my_cluster" {
  folder_id = var.folder_id
  name      = var.cluster_name
}

data "yandex_resourcemanager_folder" "my_folder" {
  folder_id = var.folder_id
}
