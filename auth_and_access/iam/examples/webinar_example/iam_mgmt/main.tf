
### IAM dev folder - change folder_id for your own
module "iam_dev_folder" {
  source                       = "../modules/iam"
  folder_binding_authoritative = true##!!!
  folder_id                    = "xxxxxx"
  folder_user_role_mapping = [
    {
      name  = "network-admin-infra"
      users = ["serviceAccount:ajek2i5oh2u0goj7siad", ] ## Pre-created SA network-admin used as IAM USER
      roles = ["viewer", "vpc.admin"]

    },
    {
      name  = "developer"
      users = ["serviceAccount:aje01koskf49t6qkdvm4", ] ## Pre-created SA av-developer-iam-prod used as IAM USER from other folder
      roles = ["compute.admin", "iam.serviceAccounts.user", "mdb.admin", "k8s.admin", "container-registry.admin", "kms.admin", "vpc.user", "viewer"]
    },
  ]
  sa_role_mapping = [
    {
      name  = "av-dev-sa-cluster"
      roles = ["editor"]

    },
    {
      name  = "av-dev-sa-nodes"
      roles = ["container-registry.images.puller"]
    },
    {
      name  = "av-dev-sa-storage"
      roles = ["storage.editor", "kms.keys.encrypterDecrypter"]
    },
  ]

}
### IAM Prod folder  - change folder_id for your own
module "iam_prod_folder" {
  source                       = "../modules/iam"
  folder_binding_authoritative = true
  folder_id                    = "XXXXXXXXXXXXXXXXXXXX"
  folder_user_role_mapping = [
    {
      name  = "network-admin-infra"
      users = ["serviceAccount:ajek2i5oh2u0goj7siad", ] ## Pre-created SA network-admin used as IAM USER
      roles = ["viewer", "vpc.admin"]

    },
    {
      name  = "developer"
      users = ["serviceAccount:ajebr23qsqedf8rpgjk5", ] ## Pre-created SA av-developer-iam used as IAM USER from other folder
      roles = ["compute.admin", "iam.serviceAccounts.user", "mdb.admin", "k8s.admin", "container-registry.admin", "kms.admin", "vpc.user", "viewer"]
    },
  ]
  sa_role_mapping = [
    {
      name  = "av-prod-sa-cluster"
      roles = ["editor"]

    },
    {
      name  = "av-prod-sa-nodes"
      roles = ["container-registry.images.puller"]
    },
    {
      name  = "av-prod-sa-storage"
      roles = ["storage.editor", "kms.keys.encrypterDecrypter"]
    },
  ]

}

### IAM infra folder  - change folder_id for your own
module "iam_infra_folder" {
  source                       = "../modules/iam"
  folder_binding_authoritative = true
  folder_id                    = "XXXXXXXXXXXXXXXXXXXX"
  folder_user_role_mapping = [
    {
      name  = "network-admin-infra"
      users = ["serviceAccount:ajek2i5oh2u0goj7siad", ] ## Pre-created SA network-admin used as IAM USER
      roles = ["viewer", "vpc.admin", "compute.admin", "load-balancer.admin",]

    },
  ]
  sa_role_mapping = [
    {
      name  = "infra-sa-cluster"
      roles = ["editor"]

    },
    {
      name  = "infra-sa-nodes"
      roles = ["container-registry.images.puller"]
    },
    {
      name  = "infra-sa-noroles"
      roles = []
    },
  ]

}
