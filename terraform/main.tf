terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    ansible = {
      source  = "nbering/ansible"
      version = "1.0.4"
    }
  }
  required_version = "~> 1.0.3"
  backend "remote" {
    organization = "the-balance"

    workspaces {
      name = "matomo"
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
  version    = var.db_version
  size       = var.db_size
  region     = var.do_region
  node_count = 1
}

resource "digitalocean_droplet" "matomo" {
  image    = "ubuntu-18-04-x64" # For Nono
  name     = "matomo-webserver"
  region   = var.do_region
  size     = "s-1vcpu-1gb" # TODO: Adjust this
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}

resource "digitalocean_ssh_key" "default" {
  name       = "Standard key"
  public_key = var.ssh_key
}

resource "digitalocean_floating_ip" "matomo-ip" {
  droplet_id = digitalocean_droplet.matomo.id
  region     = digitalocean_droplet.matomo.region
}

resource "digitalocean_firewall" "web" {
  name = "only-22-80-and-443"

  droplet_ids = [digitalocean_droplet.matomo.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    # Listing every possible GH Action runner ip here is really not feasible. We could try setting up a bastion maybe?
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol = "tcp"
    # allow everything?
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol = "udp"
    # allow everything?
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Add an A record to the domain for matomo.thebalanceffxiv.com
resource "digitalocean_record" "matomo" {
  count  = var.use_dns ? 1 : 0
  domain = "thebalanceffxiv.com"
  type   = "A"
  name   = "matomo"
  value  = digitalocean_floating_ip.matomo-ip.ip_address
}