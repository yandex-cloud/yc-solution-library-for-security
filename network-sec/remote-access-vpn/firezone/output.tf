output "output" {
  value = {
    dns_zone_id     = yandex_dns_zone.firezone-zone.id                      # DNZ zone id
    ssh_pub_key     = tls_private_key.ssh.public_key_openssh                # SSH public key for access VM
    admin_password  = random_string.firezone_admin_password.result          # admin password for Firezone Web UI
    pg_fqdn         = yandex_mdb_postgresql_cluster.pg_cluster.host.0.fqdn  # PostgreSQL cluster FQDN
    pg_pass         = random_string.postgres_user_password.result           # PostgeSQL database user password
  }
}