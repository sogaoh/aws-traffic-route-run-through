output "vpc_endpoints" {
  value = module.vpc_endpoints.endpoints
}

output "sg_vpce" {
  value = {
    id   = module.vpce_sg.security_group_id
    name = module.vpce_sg.security_group_name
  }
}
