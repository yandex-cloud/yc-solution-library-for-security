
### IAM 
module "iam" {
  #  !!! Using names instead ids
  federation_id    = "XXXXXXXXXXXXXXXXX"
  usernames_to_ids = true
  cloud_id                    = "XXXXXXXXXXXXXXXX"
  cloud_user_role_mapping = [
    {
    job_title_name  = "admins"
    iam_users_names = ["name.surname", ]
    fed_users_names = ["name.surname@yantoso.ru", ]
    roles = ["admin",]
  },
  {
    job_title_name  = "network_admins"
    users_with_ids  = ["userAccount:idxxxxxx1", "federatedUser:idxxxxxx2"]
    roles = ["vpc.admin",]
  },

  ]
  folder_id                    = "XXXXXXXXXXXXXXXX"
  folder_user_role_mapping = [
  {
    job_title_name  = "devops"
    iam_users_names = ["name.surname", ]
    fed_users_names = ["name.surname@yantoso.ru", "name2.surname@yantoso.ru"]
    users_with_ids  = []
    roles           = ["viewer", ]
  },
  {
    job_title_name  = "developer"
    iam_users_names = []
    fed_users_names = ["name.surname@yantoso.ru"]
    users_with_ids  = ["federatedUser:idxxxxxx2", "userAccount:idxxxxxx1", ]
    roles           = ["k8s.admin", ]
  },
  ]    
}

