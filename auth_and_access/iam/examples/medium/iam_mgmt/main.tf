
### IAM dev folder
module "iam_dev_folder" {
  source                       = "../modules/iam"
  folder_binding_authoritative = true ##!!!
  folder_id                    = "XXXXXXXXXXXXXXXXXXXX"
  folder_user_role_mapping = [
    {
      name  = "devops"
      users = ["serviceAccount:aje0k467i3bs3tst9d97", ] ## Pre-created SA demo-devops used as IAM USER from other folder
      roles = ["iam.serviceAccounts.user", "k8s.admin", "container-registry.admin", "storage.admin"]

    },
    {
      name  = "ci"
      users = ["serviceAccount:ajeg2qiqkhnkq3vms1eg", ] ## Pre-created SA demo-gitlab used as IAM USER from other folder
      roles = ["k8s.admin"]
    },
    {
      name  = "developers"
      users = ["serviceAccount:ajevak8egbjo8v9ddl85"] ## Pre-created SA demo-developer used as IAM USER from other folder
      roles = ["k8s.editor", "container-registry.images.puller"]
    },
  ]
  sa_role_mapping = [
    {
      name  = "dev-sa-cluster"
      roles = ["editor"]

    },
    {
      name  = "dev-sa-nodes"
      roles = ["container-registry.images.puller"]
    },
    {
      name  = "dev-sa-noroles"
      roles = []
    },
  ]

}
### IAM Prod folder
module "iam_prod_folder" {
  source                       = "../modules/iam"
  folder_binding_authoritative = false
  folder_id                    = "XXXXXXXXXXXXXXXXXXXX"
  folder_user_role_mapping = [
    {
      name  = "devops"
      users = ["serviceAccount:aje0k467i3bs3tst9d97", ] ## Pre-created SA demo-devops used as IAM USER from other folder
      roles = ["viewer", "k8s.editor", ]

    },
    {
      name  = "ci"
      users = ["serviceAccount:ajeg2qiqkhnkq3vms1eg", ] ## Pre-created SA demo-gitlab used as IAM USER from other folder
      roles = ["k8s.admin"]
    },
    {
      name  = "developers"
      users = ["serviceAccount:ajevak8egbjo8v9ddl85"] ## Pre-created SA demo-developer used as IAM USER from other folder
      roles = ["k8s.viewer", ]
    },
  ]
  sa_role_mapping = [
    {
      name  = "sa-cluster"
      roles = ["editor"]

    },
    {
      name  = "sa-nodes"
      roles = ["container-registry.images.puller"]
    },
    {
      name  = "sa-noroles"
      roles = []
    },
  ]

}
