# ==========================
# YC MDB Postgress Resources
# ==========================

resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  name = var.pg_db_name
  environment = "PRODUCTION"
  network_id = yandex_vpc_network.network-keycloak.id

  config {
    version = 14
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id = "network-ssd"
      disk_size = 10
    }
  }

  host {
    zone = var.zone
    subnet_id = yandex_vpc_subnet.keycloaksubnet[0].id
  }
}

resource "yandex_mdb_postgresql_user" "pg_user" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name = var.pg_db_user
  password = var.pg_db_pass
}

resource "yandex_mdb_postgresql_database" "pg_db" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = var.pg_db_name
  owner      = yandex_mdb_postgresql_user.pg_user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
}