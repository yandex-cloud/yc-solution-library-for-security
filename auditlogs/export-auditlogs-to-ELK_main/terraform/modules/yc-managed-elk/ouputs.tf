output "elk-pass" {
  value = random_password.passwords[0].result
  sensitive = true
}


output "elk_fqdn" {
  value = "https://c-${yandex_mdb_elasticsearch_cluster.yc-elk.id}.rw.mdb.yandexcloud.net"
}
