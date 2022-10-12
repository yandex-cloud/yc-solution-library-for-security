output "iam_profile_name" {
  value = yandex_iam_service_account.this.name
}
output "iam_profile_id" {
  value = yandex_iam_service_account.this.id
}
output "bucket_name" {
  value = yandex_storage_bucket.this.bucket
}
output "aws_key_id" {
  value = yandex_iam_service_account_static_access_key.this.access_key
}
output "aws_secret_access_key" {
  value = nonsensitive(yandex_iam_service_account_static_access_key.this.secret_key)
}
