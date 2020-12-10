provider "local" {
  version = "~> 1.4"
}

# generate Ansible inventory file
resource "local_file" "AnsibleInventory" {
  file_permission="0600"

 content = templatefile("inventory.tmpl",
 {
  node-1-dns = hcloud_server.node-1.name,
  node-1-ip = hcloud_server.node-1.ipv4_address,
  node-1-id = hcloud_server.node-1.id,
  node-2-dns = hcloud_server.node-2.name,
  node-2-ip = hcloud_server.node-2.ipv4_address,
  node-2-id = hcloud_server.node-2.id,
  node-3-dns = hcloud_server.node-3.name,
  node-3-ip = hcloud_server.node-3.ipv4_address,
  node-3-id = hcloud_server.node-3.id,
  loadbalancer-ip = hcloud_load_balancer.lb1.ipv4
 }
 )
 filename = "../ansible/inventory/hosts"
}
