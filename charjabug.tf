resource "digitalocean_firewall" "ponyta" {
  name = "ponyta"

  droplet_ids = [digitalocean_droplet.charjabug.id]

  // SSH - local only
  // TODO: source_addresses = ["10.110.0.0/16", "100.64.0.0/10"]
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = []
  }

  // ZNC
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3254"
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

  // Gemini
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1965"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  // IRC
  outbound_rule {
    protocol              = "tcp"
    port_range            = "6667"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  // Mosh
  inbound_rule {
    protocol         = "udp"
    port_range       = "60123-60456"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "60123-60456"
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

  # tags = ["fire_type"]
}

resource "digitalocean_droplet" "charjabug" {
  name      = "charjabug"
  size      = "s-1vcpu-1gb"
  image     = "ubuntu-22-04-x64"
  region    = "nyc1"
  vpc_uuid  = digitalocean_vpc.vermilion.id
  user_data = file("charjabug.yaml")
  tags      = ["electric_type", "bug_type"]
}


resource "digitalocean_record" "charjabug" {
  domain = digitalocean_domain.electroweb.id
  type   = "A"
  name   = "charjabug"
  value  = digitalocean_droplet.charjabug.ipv4_address
}

resource "digitalocean_domain" "electroweb" {
  name       = "djm.quest"
  ip_address = digitalocean_droplet.charjabug.ipv4_address
}

output "herpderp" {
  value = digitalocean_droplet.charjabug.ipv4_address
}
