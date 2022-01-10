## Example infrastructure
# Создания random-string
resource "random_string" "random" {
  length              = 4
  special             = false
  upper               = false 
}

# Создание VPC сети
resource "yandex_vpc_network" "vpc-elk" {
  name                = "vpc-elk-${random_string.random.result}"
}

# Создание подсети
resource "yandex_vpc_subnet" "elk-subnet" {
  folder_id           = var.folder_id
  count               = 3
  name                = "app-elk-${element(var.network_names, count.index)}"
  zone                = element(var.zones, count.index)
  network_id          = yandex_vpc_network.vpc-elk.id
  v4_cidr_blocks      = [element(var.app_cidrs, count.index)]
}

# Создание service account
resource "yandex_iam_service_account" "sa-bucket-creator" {
  folder_id           = var.folder_id
  name                = "sa-bucket-creator-${random_string.random.result}"
}

resource "yandex_iam_service_account" "sa-bucket-editor" {
  name                = "sa-bucket-editor-${random_string.random.result}"
  folder_id           = var.folder_id
}

# Создание статического ключа для service account
resource "yandex_iam_service_account_static_access_key" "sa-bucket-creator-sk" {
  service_account_id  = yandex_iam_service_account.sa-bucket-creator.id
}

# Назначение прав на service account
resource "yandex_resourcemanager_folder_iam_binding" "storage_admin" {
  folder_id           = var.folder_id
  role                = "storage.admin"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-creator.id}",
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "storage_editor" {
  folder_id           = var.folder_id
  role                = "storage.editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-bucket-editor.id}",
  ]
}

# Создание S3 бакета
resource "yandex_storage_bucket" "trail-bucket" {
  bucket              = "trails-audit-log-bucket-${random_string.random.result}"

  access_key          = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.access_key
  secret_key          = yandex_iam_service_account_static_access_key.sa-bucket-creator-sk.secret_key
}

# Добавление правила для HTTPS-доступа в default security group
resource "yandex_vpc_security_group_rule" "elk-https" {
  security_group_binding = yandex_vpc_network.vpc-elk.default_security_group_id
  direction              = "ingress"
  description            = "incoming-https"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 443
  protocol               = "TCP"
}

# Обязательно включить AuditTrail в UI на созданный bucket
# Обязательно включить Egress NAT для подсети COI в UI на созданный bucket

## Modules
module "yc-managed-elk" {
    source                  = "../modules/yc-managed-elk" # path to module yc-managed-elk    
    folder_id               = var.folder_id
    subnet_ids              = yandex_vpc_subnet.elk-subnet[*].id  # subnets в 3-х зонах доступности для развертывания ELK
    network_id              = yandex_vpc_network.vpc-elk.id # network id в которой будет развернут ELK
    elk_edition             = "gold"
    elk_datanode_preset     = "s2.medium"
    elk_datanode_disk_size  = 1000
    elk_public_ip           = true
    elk_name                = "elk-${random_string.random.result}"
}

module "yc-elastic-trail" {
    source                  = "../modules/yc-elastic-trail/" # path to module yc-elastic-trail
    folder_id               = var.folder_id
    elk_credentials         = module.yc-managed-elk.elk-pass
    elk_address             = module.yc-managed-elk.elk_fqdn
    bucket_name             = yandex_storage_bucket.trail-bucket.bucket
    bucket_folder           = "" # указать название префикса куда trails пишет логи в бакет, например "prefix-trails", если в корень то оставить по умолчанию пустым
    sa_id                   = yandex_iam_service_account.sa-bucket-editor.id
    coi_subnet_id           = yandex_vpc_subnet.elk-subnet[0].id
}

## Outputs
output "elk-pass" {
  # Вывод пароля ELK через команду: terraform output elk-pass
  value               = module.yc-managed-elk.elk-pass
  sensitive           = true
} 

output "elk_fqdn" {
  # Вывод FQDN для доступа к ELK 
  value               = module.yc-managed-elk.elk_fqdn
} 

output "elk-user" {
  value               = "admin"
}