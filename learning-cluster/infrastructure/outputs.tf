output "vm_ips" {
  value = flatten(module.vm[*].ip_addresses)
}

output "vm_ids" {
  value = module.vm[*].id
}

output "hostnames" {
  value = local.hostnames
}

output "ansible_inventory" {
  value = [
    {
      name  = "clientnode"
      group = "clientgroup"
      ips    = module.vm.ip_addresses
    }
  ]
}
