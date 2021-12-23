### Datasource
data "yandex_client_config" "client" {}

locals {
  folder_id = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
  cloud_id  = var.cloud_id == null ? data.yandex_client_config.client.cloud_id : var.cloud_id
  #org_id    = var.org_id == null ? data.yandex_client_config.client.organization_id : var.org_id
  org_id = var.org_id
}

### SA

resource "yandex_iam_service_account" "sa" {
  for_each  = { for v in var.sa_role_mapping : v.name => v }
  name      = each.key
  folder_id = local.folder_id
}

###Folder Permissions 

data "yandex_organizationmanager_saml_federation_user_account" "folder_account" {
  for_each      = toset(flatten([for v in var.folder_user_role_mapping : v.fed_users_names if var.federation_id != null && var.usernames_to_ids == true]))
  federation_id = var.federation_id
  name_id       = each.key
}
data "yandex_iam_user" "folder_account" {
  for_each = toset(flatten([for v in var.folder_user_role_mapping : v.iam_users_names if var.usernames_to_ids == true]))
  login    = each.key
}


locals {
  sa_role_mapping          = { for v in var.sa_role_mapping : v.name => v }
  sa_mappings              = chunklist(flatten([for k, v in yandex_iam_service_account.sa : setproduct([v.id], local.sa_role_mapping[v.name].roles)]), 2)
  folder_fed_users_names   = { for b in var.folder_user_role_mapping : b.job_title_name => flatten([for key, value in data.yandex_organizationmanager_saml_federation_user_account.folder_account : "federatedUser:${value.id}" if contains(b.fed_users_names, value.name_id)]) }
  folder_iam_users_names   = { for b in var.folder_user_role_mapping : b.job_title_name => flatten([for key, value in data.yandex_iam_user.folder_account : "userAccount:${value.id}" if contains(b.iam_users_names, value.login)]) }
  folder_users_with_ids    = { for b in var.folder_user_role_mapping : b.job_title_name => b.users_with_ids }
  folder_fed_user_mappings = flatten([for v in var.folder_user_role_mapping : setproduct(local.folder_fed_users_names[v.job_title_name], v.roles)])
  folder_iam_user_mappings = flatten([for v in var.folder_user_role_mapping : setproduct(local.folder_iam_users_names[v.job_title_name], v.roles)])
  folder_id_user_mappings  = flatten([for v in var.folder_user_role_mapping : setproduct(local.folder_users_with_ids[v.job_title_name], v.roles)])
  folder_user_mappings     = distinct(chunklist(concat(local.folder_fed_user_mappings, local.folder_iam_user_mappings, local.folder_id_user_mappings), 2))

}
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

#### NON-Authoritative

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

data "yandex_organizationmanager_saml_federation_user_account" "cloud_account" {
  for_each      = toset(flatten([for v in var.cloud_user_role_mapping : v.fed_users_names if var.federation_id != null && var.usernames_to_ids == true]))
  federation_id = var.federation_id
  name_id       = each.key
}
data "yandex_iam_user" "cloud_account" {
  for_each = toset(flatten([for v in var.cloud_user_role_mapping : v.iam_users_names if var.usernames_to_ids == true]))
  login    = each.key
}
locals {
  cloud_fed_users_names   = { for b in var.cloud_user_role_mapping : b.job_title_name => flatten([for key, value in data.yandex_organizationmanager_saml_federation_user_account.cloud_account : "federatedUser:${value.id}" if contains(b.fed_users_names, value.name_id)]) }
  cloud_iam_users_names   = { for b in var.cloud_user_role_mapping : b.job_title_name => flatten([for key, value in data.yandex_iam_user.cloud_account : "userAccount:${value.id}" if contains(b.iam_users_names, value.login)]) }
  cloud_users_with_ids    = { for b in var.cloud_user_role_mapping : b.job_title_name => b.users_with_ids }
  cloud_fed_user_mappings = flatten([for v in var.cloud_user_role_mapping : setproduct(local.cloud_fed_users_names[v.job_title_name], v.roles)])
  cloud_iam_user_mappings = flatten([for v in var.cloud_user_role_mapping : setproduct(local.cloud_iam_users_names[v.job_title_name], v.roles)])
  cloud_id_user_mappings  = flatten([for v in var.cloud_user_role_mapping : setproduct(local.cloud_users_with_ids[v.job_title_name], v.roles)])
  cloud_user_mappings     = distinct(chunklist(concat(local.cloud_fed_user_mappings, local.cloud_iam_user_mappings, local.cloud_id_user_mappings), 2))
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

### Organization Permissions 
data "yandex_organizationmanager_saml_federation_user_account" "org_account" {
  for_each      = toset(flatten([for v in var.org_user_role_mapping : v.fed_users_names if var.federation_id != null && var.usernames_to_ids == true]))
  federation_id = var.federation_id
  name_id       = each.key
}
data "yandex_iam_user" "org_account" {
  for_each = toset(flatten([for v in var.org_user_role_mapping : v.iam_users_names if var.usernames_to_ids == true]))
  login    = each.key
}
locals {
  ##### {job=[ids]}
  org_fed_users_names   = { for b in var.org_user_role_mapping : b.job_title_name => flatten([for key, value in data.yandex_organizationmanager_saml_federation_user_account.org_account : "federatedUser:${value.id}" if contains(b.fed_users_names, value.name_id)]) }
  org_iam_users_names   = { for b in var.org_user_role_mapping : b.job_title_name => flatten([for key, value in data.yandex_iam_user.org_account : "userAccount:${value.id}" if contains(b.iam_users_names, value.login)]) }
  org_users_with_ids    = { for b in var.org_user_role_mapping : b.job_title_name => b.users_with_ids }
  #####[id-role pairs] per type
  org_fed_user_mappings = flatten([for v in var.org_user_role_mapping : setproduct(local.org_fed_users_names[v.job_title_name], v.roles)])
  org_iam_user_mappings = flatten([for v in var.org_user_role_mapping : setproduct(local.org_iam_users_names[v.job_title_name], v.roles)])
  org_id_user_mappings  = flatten([for v in var.org_user_role_mapping : setproduct(local.org_users_with_ids[v.job_title_name], v.roles)])
  #####list[pairs]
  org_user_mappings     = distinct(chunklist(concat(local.org_fed_user_mappings, local.org_iam_user_mappings, local.org_id_user_mappings), 2))
}

#### Authoritative

resource "yandex_organizationmanager_organization_iam_binding" "org_binding" {
  for_each        = { for v in local.org_user_mappings : v[1] => v[0]... if var.org_binding_authoritative == true }
  organization_id = local.org_id
  members         = each.value
  role            = each.key
}

#### NON-Authoritative

resource "yandex_organizationmanager_organization_iam_member" "org_member" {
  count           = var.org_binding_authoritative == false ? length(local.org_user_mappings) : 0
  organization_id = local.org_id
  member          = element(local.org_user_mappings, count.index)[0]
  role            = element(local.org_user_mappings, count.index)[1]
}
