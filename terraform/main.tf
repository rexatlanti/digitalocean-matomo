terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  required_version = "~> 1.0.3"
  backend "remote" {
    organization = "REPLACE_ME"

    workspaces {
      name = "the-balance"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  # Use $DIGITALOCEAN_TOKEN in env
}

resource "digitalocean_database_db" "database" {
  cluster_id = digitalocean_database_cluster.matomo-backend.id
  name       = "matomo"
}

resource "digitalocean_database_cluster" "matomo-backend" {
  name       = "matomo-backend-db-cluster"
  engine     = "mysql"
  version    = "8" # TODO: Adjust this
  size       = "db-s-1vcpu-1gb" # TODO: Adjust this
  region     = "nyc1" # TODO: Adjust this
  node_count = 1
}

resource "digitalocean_droplet" "matomo" {
  image  = "ubuntu-18-04-x64" # For Nono
  name   = "matomo-webserver"
  region = "nyc1" # TODO: Adjust this
  size   = "s-1vcpu-1gb" # TODO: Adjust this
}
