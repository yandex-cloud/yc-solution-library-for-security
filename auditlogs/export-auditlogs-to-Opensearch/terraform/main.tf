## Example infrastructure
# Создания random-string
resource "random_string" "random" {
  length              = 4
  special             = false
  upper               = false 
}

# Создание VPC сети
resource "yandex_vpc_network" "vpc-opensearch" {
  name                = "vpc-opensearch-${random_string.random.result}"
}

# Создание подсети
resource "yandex_vpc_subnet" "opensearch-subnet" {
  folder_id           = var.folder_id
  count               = 3
  name                = "app-opensearch-${element(var.network_names, count.index)}"
  zone                = element(var.zones, count.index)
  network_id          = yandex_vpc_network.vpc-opensearch.id
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
#resource "yandex_vpc_security_group_rule" "opensearch-https" {
 # security_group_binding = yandex_vpc_network.vpc-opensearch.default_security_group_id
 # direction              = "ingress"
 # description            = "incoming-https"
 # v4_cidr_blocks         = ["0.0.0.0/0"]
 # port                   = 443
 # protocol               = "TCP"
#}

# Добавление правила для HTTPS-доступа в default security group
#resource "yandex_vpc_security_group_rule" "opensearch-9002" {
#  security_group_binding = yandex_vpc_network.vpc-opensearch.default_security_group_id
#  direction              = "ingress"
#  description            = "incoming-9002"
#  v4_cidr_blocks         = ["0.0.0.0/0"]
#  port                   = 9200
#  protocol               = "TCP"
#}

# Обязательно включить AuditTrail в UI на созданный bucket
# Обязательно включить Egress NAT для подсети COI в UI на созданный bucket

# ## Modules
# module "yc-managed-opensearch" {
#     source                  = "../modules/yc-managed-opensearch" # path to module yc-managed-opensearch    
#     folder_id               = var.folder_id
#     subnet_ids              = yandex_vpc_subnet.opensearch-subnet[*].id  # subnets в 3-х зонах доступности для развертывания opensearch
#     network_id              = yandex_vpc_network.vpc-opensearch.id # network id в которой будет развернут opensearch
#     opensearch_edition             = "basic"
#     opensearch_datanode_preset     = var.var_opensearch_node_preset
#     opensearch_datanode_disk_size  = var.var_opensearch_node_disk_size
#     opensearch_public_ip           = true
#     opensearch_name                = "opensearch-${random_string.random.result}"
# }

module "yc-opensearch-trail" {
    source                  = "./modules/yc-opensearch-trail/" # path to module yc-elastic-trail
    folder_id               = var.folder_id
    opensearch_pass         = var.opensearch_pass
    opensearch_address      = var.opensearch_address
    bucket_name             = yandex_storage_bucket.trail-bucket.bucket
    bucket_folder           = "" # указать название префикса куда trails пишет логи в бакет, например "prefix-trails", если в корень то оставить по умолчанию пустым
    sa_id                   = yandex_iam_service_account.sa-bucket-editor.id
    coi_subnet_id           = yandex_vpc_subnet.opensearch-subnet[0].id
}

# ## Outputs
output "bucket-for-trails" {
  value               = yandex_storage_bucket.trail-bucket.bucket
}

# output "opensearch-pass" {
#   # Вывод пароля opensearch через команду: terraform output opensearch-pass
#   value               = module.yc-managed-opensearch.opensearch-pass
#   sensitive           = true
# } 

# output "opensearch_fqdn" {
#   # Вывод FQDN для доступа к opensearch 
#   value               = module.yc-managed-opensearch.opensearch_fqdn
# } 

# output "opensearch-user" {
#   value               = "admin"
# }
