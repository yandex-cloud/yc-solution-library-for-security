
### IAM 
module "iam" {
  source = "../.."
  ## Edit with real ORG and CLOUD IDs
  org_id   = "XXXXXXXXXXXXXXXXXXXX"
  cloud_id = "XXXXXXXXXXXXXXXXXXXX"
  ## Edit with real IAM users ID
  org_user_role_mapping = [
    {
      name  = "org_network_admins"
      users = ["userAccount:ajeu8bruia5h8sl53XXX", ]
      roles = ["vpc.admin", ]
    },
  ]
  cloud_user_role_mapping = [
    {
      name  = "devops"
      users = ["userAccount:ajeu8bruia5h8sl53XXX", ]
      roles = ["editor", ]
    },
  ]
}


