module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #version = "~> 5"

  tags = {
    Managed_by = "Terragrunt"
    Env        = "soga-spike"
  }

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs            = local.vpc_azs
  public_subnets = local.pub_subnet_cidr
  private_subnets  = local.pri_subnet_cidr
  //database_subnets  = local.db_subnet_cidr

  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                                 = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_cloudwatch_log_group_retention_in_days = 30
}
