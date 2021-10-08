//----------------------Подготовка тестовой инфраструктуры-----------------------------------
// Генерация random-string для имени bucket---------------------------------------------------------

locals {
  folders_format = replace(file("./folders.txt"), "\n", ",")
  folders = split(",", local.folders_format)
}

// Создание сети
resource "yandex_vpc_network" "vpc-elk" {
  count = length(local.folders)
  folder_id = element(local.folders, count.index)
  name = "vpc-elk-${element(local.folders, count.index)}"
}


resource "yandex_vpc_subnet" "elk-subnet-a" {

  count = length(local.folders)
  folder_id = element(local.folders, count.index)

  name           = "elk-subnet-a"
  zone           = "ru-central1-a"
  network_id     = element(yandex_vpc_network.vpc-elk[*].id, count.index) 
  v4_cidr_blocks = ["192.168.1.0/24"]
}




//----------------------Создание ELK-----------------------------------

resource "yandex_mdb_elasticsearch_cluster" "yc-elk" {
  count = length(local.folders)
  folder_id = element(local.folders, count.index)
  name        = "yc-elk-${element(local.folders, count.index)}"
  environment = "PRODUCTION"
  network_id  = element(yandex_vpc_network.vpc-elk[*].id, count.index)

  config {
    edition         = var.elk_edition
    admin_password  = element(local.folders, count.index)

    data_node {
      resources {
        resource_preset_id = var.elk_datanode_preset
        disk_type_id       = "network-ssd"
        disk_size          = var.elk_datanode_disk_size
      }
    }
  }

  host {
      name              = "datanode-${element(local.folders, count.index)}"
      zone              = "ru-central1-a"
      type              = "DATA_NODE"
      assign_public_ip  = true
      subnet_id         = element(yandex_vpc_subnet.elk-subnet-a[*].id, count.index)
  }
}


//создание k8s cluster

#Create k8s cluster ------------------------------------------------------------------------
resource "yandex_kubernetes_cluster" "k8s-cluster" {
  count = length(local.folders)
  folder_id = element(local.folders, count.index)
  name        = "k8s-cluster-${element(local.folders, count.index)}"

  network_id = element(yandex_vpc_network.vpc-elk[*].id, count.index)

  master {
    version = "1.20"
    zonal {
      zone      = "ru-central1-a"
      subnet_id = element(yandex_vpc_subnet.elk-subnet-a[*].id, count.index)
    }

    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = element(yandex_iam_service_account.editor-sa[*].id, count.index)
  node_service_account_id = element(yandex_iam_service_account.editor-sa[*].id, count.index)
  
  release_channel = "RAPID"
  network_policy_provider = "CALICO"

/*
  depends_on = [
  element(yandex_resourcemanager_folder_iam_binding.editor-sa-binding[*].id, count.index)
]
*/
}


#Create k8s nodes-----------------------------------------------------------------------------------
resource "yandex_kubernetes_node_group" "my_node_group" {
  count = length(local.folders)
//  folder_id = element(local.folders, count.index)
  cluster_id  = element(yandex_kubernetes_cluster.k8s-cluster[*].id, count.index)
  
  name        = "my-nodes-${element(local.folders, count.index)}"
  description = "description"
  version     = "1.20"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = [element(yandex_vpc_subnet.elk-subnet-a[*].id, count.index)]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }
  }
}




# Create service accounts for k8s------------------------------------------------------------------

resource "yandex_iam_service_account" "editor-sa" {
  count = length(local.folders)
  folder_id = element(local.folders, count.index)
  name        = "editor-sa-${element(local.folders, count.index)}"
}


#Bind iam policy to service accounts----------------------------------------------------------------

resource "yandex_resourcemanager_folder_iam_binding" "editor-sa-binding" {
  count = length(local.folders)
  folder_id = element(local.folders, count.index)

  role = "editor"

  members = [
    "serviceAccount:${element(yandex_iam_service_account.editor-sa[*].id, count.index)}",
  ]
}

//Create sa for trails-----------------------------------
resource "yandex_iam_service_account" "trails-sa" {
  count = length(local.folders)
  folder_id = element(local.folders, count.index)
  name        = "trails-sa-${element(local.folders, count.index)}"
}

resource "yandex_resourcemanager_cloud_iam_binding" "trails-sa-binding" {
  count = length(local.folders)
 # folder_id = element(local.folders, count.index)
  cloud_id = var.cloud_id

  role = "audit-trails.viewer"

  members = [
    "serviceAccount:${element(yandex_iam_service_account.trails-sa[*].id, count.index)}",
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "trails-sa-binding2" {
  count = length(local.folders)
  folder_id = element(local.folders, count.index)

  role = "editor"

  members = [
    "serviceAccount:${element(yandex_iam_service_account.trails-sa[*].id, count.index)}",
  ]
}