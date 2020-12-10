#
# Basics
#

# Set the variables values in terraform.tfvars
variable "private_key_path" {}
variable "public_key_path" {}

# Setup OS image
variable "os_image" {
  type    = string
  default = "ubuntu-20.04"
}

# Setup server type
variable "server_type" {
  type    = string
  default = "cx21"
}

# Import SSH key
resource "hcloud_ssh_key" "access-ssh-key" {
  name       = "access-ssh-key"
  public_key = file(var.public_key_path)
}

#
# Networking
#

# Setup network
resource "hcloud_network" "vpc1" {
  name     = "vpc1"
  ip_range = "10.0.0.0/16"
}

# Setup subnet
resource "hcloud_network_subnet" "vpc1-subnet1" {
  network_id   = hcloud_network.vpc1.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

# Setup server networking
resource "hcloud_server_network" "nodes-network" {
  count       = var.node_count
  network_id  = hcloud_network.vpc1.id
  server_id   = element(hcloud_server.nodes.*.id, count.index)
  ip          = cidrhost(hcloud_network_subnet.vpc1-subnet1.ip_range, count.index+2)
}

#
# Loadbalancing
#

resource "hcloud_load_balancer" "lb1" {
  name               = "lb1"
  load_balancer_type = "lb11"
  # network_zone = "eu-central"
  location = "nbg1"
  labels   = { role = "loadbalancer" }
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_network" "lb1-network" {
  load_balancer_id        = hcloud_load_balancer.lb1.id
  subnet_id               = hcloud_network_subnet.vpc1-subnet1.id
  enable_public_interface = true
  ip                      = "10.0.0.15"
}

resource "hcloud_load_balancer_target" "lb1-targets" {
  count            = var.node_count
  type             = "server"
  load_balancer_id = hcloud_load_balancer.lb1.id
  server_id        = element(hcloud_server.nodes.*.id, count.index)
  use_private_ip   = true
}

# resource "hcloud_load_balancer_target" "lb1-target-node-1" {
#   type             = "server"
#   load_balancer_id = hcloud_load_balancer.lb1.id
#   server_id        = hcloud_server.node-1.id
#   use_private_ip   = true
#   depends_on = [
#     hcloud_server_network.node-1-network,
#     hcloud_load_balancer_network.lb1-network
#   ]
# }

# resource "hcloud_load_balancer_target" "lb1-target-node-2" {
#   type             = "server"
#   load_balancer_id = hcloud_load_balancer.lb1.id
#   server_id        = hcloud_server.node-2.id
#   use_private_ip   = true
#   depends_on = [
#     hcloud_server_network.node-2-network,
#     hcloud_load_balancer_network.lb1-network
#   ]
# }

# resource "hcloud_load_balancer_target" "lb1-target-node-3" {
#   type             = "server"
#   load_balancer_id = hcloud_load_balancer.lb1.id
#   server_id        = hcloud_server.node-3.id
#   use_private_ip   = true
#   depends_on = [
#     hcloud_server_network.node-3-network,
#     hcloud_load_balancer_network.lb1-network
#   ]
# }

resource "hcloud_load_balancer_service" "lb1-service" {
  load_balancer_id = hcloud_load_balancer.lb1.id
  protocol         = "http"
  listen_port      = 80
  destination_port = 80
  health_check {
    protocol = "http"
    port     = 80
    interval = 15
    timeout  = 10
    http {
      domain = "www.gitea.local"
    }
  }
}

#
# Servers
#

# Server amount
variable "node_count" {
  default  = 3
}

resource "hcloud_server" "nodes" {
  count          = var.node_count
  name          = "node-${count.index+1}"
  image         = var.os_image
  server_type   = var.server_type
  location      = "nbg1"
  ssh_keys      = [hcloud_ssh_key.access-ssh-key.id]
  labels        = { role = "node" }
}