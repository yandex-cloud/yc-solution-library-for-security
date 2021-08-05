### Datasource
data "terraform_remote_state" "sa" {
  backend = "local"
  config = {
    path = "../iam_mgmt/terraform.tfstate"
  }
}

### Networking
module "vpc" {
  source              = "../modules/networking"
  labels              = var.labels
  network_description = var.network_description
  network_name        = "${var.env}-${var.network_name}"
  folder_id           = var.folder_id
  subnets             = var.subnets
}

### Container Registry

resource "yandex_container_registry" "registry" {
  folder_id = var.folder_id
  name      = "${var.env}-registry"
}

### Kubernetes cluster

resource "yandex_kubernetes_cluster" "regional_cluster" {
  folder_id  = var.folder_id
  name       = "${var.env}-demo"
  network_id = module.vpc.id
  master {
    regional {
      region = "ru-central1"

      dynamic "location" {
        for_each = module.vpc.subnets
        content {
          zone      = location.value.zone
          subnet_id = location.value.id
        }
      }
    }
    version   = var.k8s_version
    public_ip = true

    maintenance_policy {
      auto_upgrade = true
    }
  }
  service_ipv4_range      = var.k8s_service_ipv4_range
  cluster_ipv4_range      = var.k8s_pod_ipv4_range
  release_channel         = var.release_channel
  network_policy_provider = "CALICO"
  service_account_id      = data.terraform_remote_state.sa.outputs.dev_sa["av-dev-sa-cluster"].id
  node_service_account_id = data.terraform_remote_state.sa.outputs.dev_sa["av-dev-sa-nodes"].id

  labels     = var.labels
  depends_on = [module.vpc, ]
}

# ### K8s Node Groups

# resource "yandex_kubernetes_node_group" "nodes" {
#   cluster_id = yandex_kubernetes_cluster.regional_cluster.id
#   name       = "ng-${var.env}"
#   version    = var.k8s_version

#   instance_template {
#     platform_id = "standard-v2"
#     nat         = true

#     resources {
#       memory = 4
#       cores  = 2
#     }

#     boot_disk {
#       type = "network-ssd"
#       size = 64
#     }

#     scheduling_policy {
#       preemptible = false
#     }
#   }

#   scale_policy {
#     fixed_scale {
#       size = 3
#     }
#   }

#   allocation_policy {
#     dynamic "location" {
#       for_each = module.vpc.subnets
#       content {
#         zone      = location.value.zone
#         subnet_id = location.value.id
#       }
#     }
#   }

#   maintenance_policy {
#     auto_upgrade = true
#     auto_repair  = true
#   }
# }
