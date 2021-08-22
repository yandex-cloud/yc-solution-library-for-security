output "staging_cluster_sa" {
  value       =  module.staging_folder.sa["sa-staging-cluster"].id
}

output "staging_nodes_sa" {
  value       =  module.staging_folder.sa["sa-staging-nodes"].id
}

output "prod_cluster_sa" {
  value       =  module.prod_folder.sa["sa-prod-cluster"].id
}

output "prod_nodes_sa" {
  value       =  module.prod_folder.sa["sa-prod-nodes"].id
}