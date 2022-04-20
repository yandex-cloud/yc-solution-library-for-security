output "service_account_id" {
  value     = data.yandex_iam_service_account.bucket_sa.id
  sensitive = true
}

output "folder_id" {
  value     = data.yandex_resourcemanager_folder.my_folder.id
  sensitive = true
}

output "log_bucket_name" {
  value     = var.log_bucket_name
  sensitive = true
}
