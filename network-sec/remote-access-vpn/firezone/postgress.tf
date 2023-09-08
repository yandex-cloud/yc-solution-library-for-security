resource "random_string" "postgres_user_password" {
  length  = 12
  upper   = true
  lower   = true
  numeric  = true
  special = true
  override_special = "!@%&*()-_=+[]{}<>:?"
}

resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  folder_id   = var.values.folder_id
  name        = "pg_cluster"
  environment = "PRODUCTION"
  network_id  = var.values.vpc_id
  security_group_ids = [yandex_vpc_security_group.postgres-sg.id]

  config {
    version = var.values.postgres.db_ver
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.firezone-subnet.id
  }
}

resource "yandex_mdb_postgresql_user" "pg_user" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = var.values.postgres.db_user
  password   = random_string.postgres_user_password.result
}

resource "yandex_mdb_postgresql_database" "pg_kc_db" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = var.values.postgres.db_kc_name
  owner      = yandex_mdb_postgresql_user.pg_user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
}

resource "yandex_mdb_postgresql_database" "pg_firezone_db" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = var.values.postgres.db_firezone_name
  owner      = yandex_mdb_postgresql_user.pg_user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  extension {
    name = "pgcrypto"
  }
  extension {
    name = "btree_gist"
  }
  extension {
    name = "citext"
  }
}