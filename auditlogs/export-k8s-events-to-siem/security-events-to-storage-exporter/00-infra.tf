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
    host     = data.yandex_kubernetes_cluster.my_cluster.master.0.public_ip == true ?   data.yandex_kubernetes_cluster.my_cluster.master.0.external_v4_endpoint : data.yandex_kubernetes_cluster.my_cluster.master.0.internal_v4_endpoint 
    cluster_ca_certificate = data.yandex_kubernetes_cluster.my_cluster.master.0.cluster_ca_certificate
    token                  = data.yandex_client_config.client.iam_token

  }
}

data "local_file" "yc-mk8s-ca" {
    filename = "${path.module}/templates/yc-mk8s.ca"
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig-template.yaml.tpl")
  vars = {
      context                = var.cluster_name
      cluster_ca_certificate = data.local_file.yc-mk8s-ca.content
      endpoint               = data.yandex_kubernetes_cluster.my_cluster.master.0.public_ip == true ?   data.yandex_kubernetes_cluster.my_cluster.master.0.external_v4_endpoint : data.yandex_kubernetes_cluster.my_cluster.master.0.internal_v4_endpoint 
      token                  = data.yandex_client_config.client.iam_token
    }

  
}

resource "local_file" "kubeconfig" {
    content     = data.template_file.kubeconfig.rendered
    filename = "${path.cwd}/foo.bar"
}



provider "kustomization" {
  
  kubeconfig_raw = data.template_file.kubeconfig.rendered

}

output "cluster" {
  description = "A kubeconfig file configured to access the GKE cluster."
  value       = data.yandex_kubernetes_cluster.my_cluster.master
}

output "kubeconfig_raw" {
  description = "A kubeconfig file configured to access the GKE cluster."
  value       =  data.template_file.kubeconfig.rendered
}

/*
locals {
 kubeconfig_raw_vars = {
      context                = var.cluster_name
      cluster_ca_certificate = data.yandex_kubernetes_cluster.my_cluster.master.0.cluster_ca_certificate
      endpoint               = data.yandex_kubernetes_cluster.my_cluster.master.0.public_ip == true ?   data.yandex_kubernetes_cluster.my_cluster.master.0.external_v4_endpoint : data.yandex_kubernetes_cluster.my_cluster.master.0.internal_v4_endpoint 
      token                  = data.yandex_client_config.client.iam_token 
      }
}
locals {

  kubeconfig_raw = trim(yamlencode(templatefile("${path.module}/templates/kubeconfig-template.yaml.tpl",local.kubeconfig_raw_vars)),"|-")
  }


output "kubeconfig_raw" {
  sensitive = true
  description = "A kubeconfig file configured to access the GKE cluster."
  value       = local.kubeconfig_raw
}
*/


