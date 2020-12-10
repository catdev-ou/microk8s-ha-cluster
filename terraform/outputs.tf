output "server-ips" {
  value = [
    hcloud_server.node-1.ipv4_address,
    hcloud_server.node-2.ipv4_address,
    hcloud_server.node-3.ipv4_address
  ]
}

output "loadbalancer-ip" {
  value = hcloud_load_balancer.lb1.ipv4
}
