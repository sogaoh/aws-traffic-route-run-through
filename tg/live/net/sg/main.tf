module "external_sg" {
  source = "terraform-aws-modules/security-group/aws"

  tags = {
    Managed_by = "Terragrunt"
    Env        = "soga-spike"
  }

  name            = local.external_sg_name
  use_name_prefix = false
  description     = local.external_sg_description
  vpc_id          = data.terraform_remote_state.net_vpc.outputs.vpc.id

  ingress_cidr_blocks = [
    local.all_network_cidr,
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = local.all_network_cidr
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.all_network_cidr
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = data.terraform_remote_state.net_vpc.outputs.vpc.cidr
    }

  ]
  egress_with_cidr_blocks = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      # tfsec:ignore:aws-ec2-no-public-egress-sgr
      cidr_blocks = local.all_network_cidr
    },
  ]
}

module "internal_sg" {
  source = "terraform-aws-modules/security-group/aws"

  tags = {
    Managed_by = "Terragrunt"
    Env        = "sogaoh-spike"
  }

  name            = local.internal_sg_name
  use_name_prefix = false
  description     = local.internal_sg_description
  vpc_id          = data.terraform_remote_state.net_vpc.outputs.vpc.id

  ingress_cidr_blocks = [
    data.terraform_remote_state.net_vpc.outputs.vpc.cidr,
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.external_sg.security_group_id
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = data.terraform_remote_state.net_vpc.outputs.vpc.cidr
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = data.terraform_remote_state.net_vpc.outputs.vpc.cidr
    },
    {
      //Node.js
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = data.terraform_remote_state.net_vpc.outputs.vpc.cidr
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = data.terraform_remote_state.net_vpc.outputs.vpc.cidr
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      # tfsec:ignore:aws-ec2-no-public-egress-sgr
      cidr_blocks = local.all_network_cidr
    }
  ]
}

module "storage_sg" {
  source = "terraform-aws-modules/security-group/aws"

  tags = {
    Managed_by = "Terragrunt"
    Env        = "sogaoh-spike"
  }

  name            = local.storage_sg_name
  use_name_prefix = false
  description     = local.storage_sg_description
  vpc_id          = data.terraform_remote_state.net_vpc.outputs.vpc.id

  ingress_cidr_blocks = [
    data.terraform_remote_state.net_vpc.outputs.vpc.cidr,
  ]

  ingress_with_source_security_group_id = [
    {
      //MySQL
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.internal_sg.security_group_id
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      # tfsec:ignore:aws-ec2-no-public-egress-sgr
      cidr_blocks = local.all_network_cidr
    }
  ]
}
