resource "yandex_kubernetes_cluster" "staging_cluster" {

  name        = "k8s-staging-cluster01"

  network_id = "${yandex_vpc_network.k8s_vpc.id}"

  master {
    version = var.k8s_version
    zonal {
      zone      = "${yandex_vpc_subnet.k8s_subnet.zone}"
      subnet_id = "${yandex_vpc_subnet.k8s_subnet.id}"
    }

    public_ip = true

    
  }

  service_account_id      = var.cluster_sa_id
  node_service_account_id = var.nodes_sa_id


  release_channel = "REGULAR"
  network_policy_provider = "CALICO"


}

resource "yandex_kubernetes_node_group" "staging_clusternode_group" {
  
  cluster_id  = "${yandex_kubernetes_cluster.staging_cluster.id}"
  name        = "k8s-staging-cluster-ng01"
  description = "description"
  version     = var.k8s_version

  labels = {
    country       = "ru"
  }

  instance_template {
    platform_id = "standard-v2"
    nat = true
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    
  }

  scale_policy {
    fixed_scale {
      size = 4
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  
}