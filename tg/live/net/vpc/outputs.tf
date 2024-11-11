output "vpc" {
  value = {
    id   = module.vpc.vpc_id
    cidr = module.vpc.vpc_cidr_block
    azs  = module.vpc.azs
  }
}

output "subnet" {
  value = {
    public_ids   = module.vpc.public_subnets
    public_cidrs = module.vpc.public_subnets_cidr_blocks
    private_ids   = module.vpc.private_subnets
    private_cidrs = module.vpc.private_subnets_cidr_blocks
    //database_ids   = module.vpc.database_subnets
    //database_cidrs = module.vpc.database_subnets_cidr_blocks
  }
}

output "igw" {
  value = {
    id  = module.vpc.igw_id
    arn = module.vpc.igw_arn
  }
}

output "vpc_flow_log" {
  value = {
    id       = module.vpc.vpc_flow_log_id
    cw_group = split(":", module.vpc.vpc_flow_log_destination_arn)[length(split(":", module.vpc.vpc_flow_log_destination_arn)) - 1]
  }
}

output "route_table" {
  value = {
    public_ids = module.vpc.public_route_table_ids
    private_ids = module.vpc.private_route_table_ids
    //database_ids = module.vpc.database_route_table_ids
  }
}
