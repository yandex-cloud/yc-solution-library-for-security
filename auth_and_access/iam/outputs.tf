output "ids" {
  description = "List IDs of created service accounts"
  value       = [for v in yandex_iam_service_account.sa : v.id]
}

output "names" {
  description = "List Names of created service accounts"
  value       = [for v in yandex_iam_service_account.sa : v.name]
}
output "sa" {
  description = "Map with service accounts info , key = service account name"
  value       = { for v in yandex_iam_service_account.sa : v.name => v }
}
