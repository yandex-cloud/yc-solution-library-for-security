# =======================================
# IPsec Security Gateway (SGW) deployment
# Outputs
# =======================================

# ipsec-configs
output "subnets_pairs" {
  description = "Subnet pairs for Remote SGW which is not supported Route-based policies, such as Mikrotik CHR."
  value       = local.subnets_pairs
}

# vpc
output "yc_rt_cmd" {
  description = "Provide yc CLI command string for change traffic flow via route-table manually."
  value       = var.yc_subnets.force_subnets_update ? "true" : local.yc_rt_cmd
}
