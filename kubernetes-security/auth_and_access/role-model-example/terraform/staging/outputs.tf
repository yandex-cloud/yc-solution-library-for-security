
output "cluster_id" {
  value       =  yandex_kubernetes_cluster.staging_cluster.id
}

output "default_sg_id" {
  value       =  yandex_vpc_network.k8s_vpc.default_security_group_id
}