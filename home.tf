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
  resources = [
    digitalocean_app.home.urn,
    digitalocean_droplet.charjabug.urn,
    digitalocean_volume.loudred.urn,
    digitalocean_domain.electroweb.urn
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

resource "digitalocean_volume" "loudred" {
  region                   = "nyc1"
  name                     = "loudred"
  size                     = 2
  initial_filesystem_type  = "ext4"
  initial_filesystem_label = "loudred"
  tags                     = ["normal_type"]
}

resource "digitalocean_volume_attachment" "roar" {
  droplet_id = digitalocean_droplet.charjabug.id
  volume_id  = digitalocean_volume.loudred.id
}


# https://github.com/hashicorp/terraform/issues/23893
module "test" {
  source = "matti/urlparse/external"
  url    = digitalocean_app.home.live_url
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.electroweb.id
  type   = "CNAME"
  name   = "www"
  value  = "${module.test.host}."
}
