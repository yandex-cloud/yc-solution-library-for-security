### IAM 
module "staging_folder" {
  source                       = "../modules/iam"
  folder_id                    = var.staging_folder_id
  folder_binding_authoritative = true

  sa_role_mapping = [
    {
      name  = "sa-staging-cluster"
      roles = ["k8s.clusters.agent","vpc.publicAdmin"]
    },
    {
      name  = "sa-staging-nodes"
      roles = ["container-registry.images.puller"]
    },
  ]
  

folder_user_role_mapping = [
       {
         users = var.user_group_mapping.devops
         roles = [ 
         "k8s.admin",
         "vpc.admin", 
         "compute.admin",
         "k8s.cluster-api.cluster-admin", 
         "container-registry.admin",
         "iam.serviceAccounts.user",
         "vpc.user",
         "viewer"
         ]

       },
       {
         users = var.user_group_mapping.developers
         roles = [ 
          "k8s.cluster-api.editor",
          "container-registry.images.pusher",
          "viewer",
       
     ]
}
]
}
module "prod_folder" {
  source                       = "../modules/iam"
  folder_id                    = var.prod_folder_id
  folder_binding_authoritative = true

  sa_role_mapping = [
    {
      name  = "sa-prod-cluster"
      roles = ["k8s.clusters.agent"]
    },
    {
      name  = "sa-prod-nodes"
      roles = ["container-registry.images.puller"]
    },
  ]

folder_user_role_mapping = [
       {
         users = var.user_group_mapping.devops
         roles = [ 
         "k8s.admin",
         "vpc.privateAdmin", 
         "k8s.cluster-api.cluster-admin", 
         "container-registry.admin",
         "iam.serviceAccounts.user",
         "vpc.user",
         "viewer"
         ]

       },
       {
         users = var.user_group_mapping.developers
         roles = [ 
          "viewer",
          ]
      }
    ]
  }
