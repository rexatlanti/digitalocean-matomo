output "db-host" {
  value = digitalocean_database_cluster.matomo-backend.private_host
}

output "matomo-host" {
  value = digitalocean_floating_ip.matomo-ip.ip_address
}