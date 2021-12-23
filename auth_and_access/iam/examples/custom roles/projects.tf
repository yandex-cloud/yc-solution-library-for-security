
### IAM 
module "iam_dev_project" {
  source    = "../.."
  cloud_id  = var.cloud_id
  org_id    = var.org_id
  folder_id = var.dev_folder_id
  folder_user_role_mapping = [
    {
      name  = "project_admins"
      users = var.groups.project_admins
      roles = ["admin", ]
    },
    {
      name  = "project_developers"
      users = var.groups.project_developers
      roles = var.role_dev_project_developer
    },
  ]
}
module "iam_prod_project" {
  source    = "../.."
  cloud_id  = var.cloud_id
  org_id    = var.org_id
  folder_id = var.prod_folder_id
  folder_user_role_mapping = [
    {
      name  = "project_admins"
      users = var.groups.project_admins
      roles = ["admin", ]
    },
    {
      name  = "project_developers"
      users = var.groups.project_developers
      roles = var.role_prod_project_developer
    },
  ]
}


