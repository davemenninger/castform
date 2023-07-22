terraform {
  required_version = "~> 1.5.3"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {}

resource "digitalocean_project" "castform" {
  name        = "castform"
  description = "a smol home in the cloud"
  resources   = [
    digitalocean_app.home.urn, 
    digitalocean_droplet.charjabug.urn,
    digitalocean_volume.loudred.urn
  ]
}

resource "digitalocean_app" "home" {
  spec {
    name   = "landing-page"
    region = "ams"

    static_site {
      catchall_document = "index.html"
      name              = "ohai"

      git {
        branch         = "main"
        repo_clone_url = "https://github.com/davemenninger/castform.git"
      }
    }
  }
}

resource "digitalocean_vpc" "vermilion" {
  name     = "vermilion"
  region   = "nyc1"
  ip_range = "10.110.0.0/16"
}

resource "digitalocean_firewall" "ponyta" {
  name = "ponyta"

  droplet_ids = [digitalocean_droplet.charjabug.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_droplet" "charjabug" {
  name      = "charjabug"
  size      = "s-1vcpu-1gb"
  image     = "ubuntu-22-04-x64"
  region    = "nyc1"
  vpc_uuid  = digitalocean_vpc.vermilion.id
  user_data = file("charjabug.yaml")
  tags = ["electric_type", "bug_type"]
}

output "herpderp" {
  value = digitalocean_droplet.charjabug.ipv4_address
}

resource "digitalocean_volume" "loudred" {
  region = "nyc1"
  name = "loudred"
  size = 2
  initial_filesystem_type = "ext4"
  initial_filesystem_label = "loudred"
  tags = ["normal_type"]
}

resource "digitalocean_volume_attachment" "roar" {
  droplet_id = digitalocean_droplet.charjabug.id
  volume_id  = digitalocean_volume.loudred.id
}
