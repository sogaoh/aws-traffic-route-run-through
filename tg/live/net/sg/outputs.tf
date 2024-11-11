output "sg_external" {
  value = {
    id   = module.external_sg.security_group_id
    name = module.external_sg.security_group_name
  }
}

output "sg_internal" {
  value = {
    id   = module.internal_sg.security_group_id
    name = module.internal_sg.security_group_name
  }
}

output "sg_storage" {
  value = {
    id   = module.storage_sg.security_group_id
    name = module.storage_sg.security_group_name
  }
}
