output "lb_ip" {
  value = module.lb.listener
}
output "public_ip" {
  value = module.vm.vm_public_ip
}
output "private_ip" {
  value = module.vm.vm_private_ip
}
