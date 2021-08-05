
### IAM 
### Datasource
data "yandex_client_config" "client" {}

locals {
  folder_id = var.folder_user_role_mapping == [] && var.sa_role_mapping == [] ? data.yandex_client_config.client.folder_id : var.folder_id
  cloud_id  = var.cloud_id == null ? data.yandex_client_config.client.cloud_id : var.cloud_id
}
### SA
resource "yandex_iam_service_account" "sa" {
  for_each  = { for v in var.sa_role_mapping : v.name => v }
  name      = each.key
  folder_id = local.folder_id
}

locals {
  folder_user_mappings = chunklist(flatten([for v in var.folder_user_role_mapping : setproduct(v.users, v.roles)]), 2)
  sa_role_mapping      = { for v in var.sa_role_mapping : v.name => v }
  sa_mappings          = chunklist(flatten([for k, v in yandex_iam_service_account.sa : setproduct([v.id], local.sa_role_mapping[v.name].roles)]), 2)
}
###Folder Permissions 

#### Authoritative
data "yandex_iam_policy" "bindings" {
  count = var.folder_binding_authoritative == false ? 0 : 1
  dynamic "binding" {
    for_each = [for v in local.folder_user_mappings : {
      member = v[0],
      role   = v[1]
    }]
    content {
      role    = binding.value.role
      members = [binding.value.member, ]
    }
  }
  dynamic "binding" {
    for_each = [for v in local.sa_mappings : {
      member = v[0],
      role   = v[1]
    }]
    content {
      role    = binding.value.role
      members = ["serviceAccount:${binding.value.member}", ]
    }
  }
}

resource "yandex_resourcemanager_folder_iam_policy" "folder_bindings_policy" {
  count       = var.folder_binding_authoritative == false ? 0 : 1
  folder_id   = local.folder_id
  policy_data = data.yandex_iam_policy.bindings[0].policy_data
}

####Permissions NON-Authoritative

resource "yandex_resourcemanager_folder_iam_member" "folder_sa_member" {
  count     = var.folder_binding_authoritative == false ? length(local.sa_mappings) : 0
  folder_id = local.folder_id
  member    = "serviceAccount:${element(local.sa_mappings, count.index)[0]}"
  role      = element(local.sa_mappings, count.index)[1]
}

resource "yandex_resourcemanager_folder_iam_member" "folder_user_member" {
  count     = var.folder_binding_authoritative == false ? length(local.folder_user_mappings) : 0
  folder_id = local.folder_id
  member    = element(local.folder_user_mappings, count.index)[0]
  role      = element(local.folder_user_mappings, count.index)[1]
}
### Cloud Permissions 
locals {
  cloud_user_mappings = chunklist(flatten([for v in var.cloud_user_role_mapping : setproduct(v.users, v.roles)]), 2)
}
#### Authoritative

resource "yandex_resourcemanager_cloud_iam_binding" "cloud_binding" {
  for_each = { for v in local.cloud_user_mappings : v[1] => v[0]... if var.cloud_binding_authoritative == true }
  cloud_id = local.cloud_id
  members  = each.value
  role     = each.key
}

#### NON-Authoritative

resource "yandex_resourcemanager_cloud_iam_member" "cloud_member" {
  count    = var.cloud_binding_authoritative == false ? length(local.cloud_user_mappings) : 0
  cloud_id = local.cloud_id
  member   = element(local.cloud_user_mappings, count.index)[0]
  role     = element(local.cloud_user_mappings, count.index)[1]
}
