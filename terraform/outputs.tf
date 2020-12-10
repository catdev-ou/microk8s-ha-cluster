output "server-ips" {
  value = [
    hcloud_server.nodes.*.ipv4_address
  ]
}

output "loadbalancer-ip" {
  value = hcloud_load_balancer.lb1.ipv4
}
