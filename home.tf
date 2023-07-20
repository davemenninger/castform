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
  resources   = [digitalocean_app.home.urn, digitalocean_droplet.charjabug.urn]
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
  // no inbound yet
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
  name     = "charjabug"
  size     = "s-1vcpu-1gb"
  image    = "ubuntu-22-04-x64"
  region   = "nyc1"
  vpc_uuid = digitalocean_vpc.vermilion.id
}
