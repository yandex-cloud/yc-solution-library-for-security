# ==========================
# YC MDB Postgress Resources
# ==========================

resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  folder_id = "${data.yandex_resourcemanager_folder.kc_folder.id}"
  name = var.pg_db_name
  environment = "PRODUCTION"
  network_id = "${data.yandex_vpc_network.kc_net.id}"

  config {
    version = var.pg_db_ver
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id = "network-ssd"
      disk_size = 10
    }
  }

  host {
    zone = var.kc_zone_id
    subnet_id = "${data.yandex_vpc_subnet.kc_subnet.id}"
  }
}

resource "yandex_mdb_postgresql_user" "pg_user" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name = var.pg_db_user
  password = var.pg_db_pass
}

resource "yandex_mdb_postgresql_database" "pg_db" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name = var.pg_db_name
  owner = yandex_mdb_postgresql_user.pg_user.name
  lc_collate = "en_US.UTF-8"
  lc_type = "en_US.UTF-8"
}
