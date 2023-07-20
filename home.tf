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
  resources = [digitalocean_app.home.urn]
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
