output "host_vm_ips" {
  value = flatten(module.host_vm[*].ip_addresses)
}

output "host_vm_ids" {
  value = module.host_vm[*].id
}

output "client_vm_ips" {
  value = flatten(module.client_vm[*].ip_addresses)
}

output "client_vm_ids" {
  value = module.client_vm[*].id
}

output "hostnames" {
  value = local.hostnames
}

output "ansible_inventory" {
  value = [
    {
      name  = "hostnode"
      group = "hostgroup"
      ips    = module.host_vm.ip_addresses
    },
    {
      name  = "clientnode"
      group = "clientgroup"
      ips    = module.client_vm.ip_addresses
    }
  ]
}
