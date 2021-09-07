
### IAM 
module "iam_org" {
  source = "../.."
  org_id = var.org_id
  org_user_role_mapping = [
    {
      name  = "organization_admins"
      users = var.groups.org_admins
      roles = ["admin", ]
    },
    {
      name  = "organization__network_admins"
      users = var.groups.network_admins
      roles = var.role_network_admin
    },
    {
      name  = "organization_sec_ops"
      users = var.groups.sec_ops
      roles = var.role_sec_ops
    },
  ]
}
