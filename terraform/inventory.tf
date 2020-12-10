provider "local" {
  version = "~> 1.4"
}

# generate Ansible inventory file
resource "local_file" "AnsibleInventory" {
  file_permission="0600"

 content = templatefile("inventory.tmpl",
 {
  node-dns = hcloud_server.nodes.*.name,
  node-ip = hcloud_server.nodes.*.ipv4_address,
  node-id = hcloud_server.nodes.*.id
  loadbalancer-ip = hcloud_load_balancer.lb1.ipv4
 }
 )
 filename = "../ansible/inventory/hosts"
}
