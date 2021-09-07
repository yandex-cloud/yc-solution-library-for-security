
### IAM 
module "iam" {
  source                       = "../.."
  folder_id                    = "XXXXXXXXXXXXXXXXXXX"
  folder_binding_authoritative = false

  sa_role_mapping = [
    {
      name  = "sa-cluster"
      roles = ["editor"]
    },
    {
      name  = "sa-noroles"
      roles = []
    },
    {
      name  = "sa-nodes"
      roles = ["container-registry.images.puller"]
    },
  ]

  ## Edit with real IAM users ID
  folder_user_role_mapping = [
    {
      name  = "devops"
      users = ["serviceAccount:aje0k467i3bs3tst9d97", ]
      roles = ["iam.serviceAccounts.user", "k8s.admin", "k8s.cluster-api.cluster-admin", "container-registry.admin"]

    },
    {
      name  = "secops"
      users = ["serviceAccount:ajeg2qiqkhnkq3vms1eg", ]
      roles = []
    },
    {
      name  = "developers"
      users = ["serviceAccount:ajevak8egbjo8v9ddl85", ]
      roles = ["k8s.viewer", "k8s.cluster-api.editor"]
    },
  ]
}


