
### IAM 
module "iam_cloud" {
  source   = "../.."
  org_id   = var.org_id
  cloud_id = var.cloud_id
  cloud_user_role_mapping = [
    {
      name  = "cloud_admins"
      users = var.groups.cloud_admins
      roles = ["admin", ]
    },
    {
      name = "cloud_members"
      ### Role Cloud.Member is needed for all users for UI enabling
      users = concat(var.groups.project_developers, var.groups.project_admins, var.groups.org_admins, var.groups.network_admins, var.groups.sec_ops, var.groups.cloud_admins)
      roles = ["resource-manager.clouds.member", ]
    },
  ]
}


