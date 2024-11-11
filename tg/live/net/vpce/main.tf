module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  tags = {
    Managed_by = "Terragrunt"
    Env        = "soga-spike"
  }

  vpc_id = data.terraform_remote_state.net_vpc.outputs.vpc.id
  security_group_ids = [
    data.terraform_remote_state.net_sg.outputs.sg_internal.id,
    data.terraform_remote_state.net_sg.outputs.sg_storage.id,
  ]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        data.terraform_remote_state.net_vpc.outputs.route_table.public_ids,
      ])
      tags = { Name = local.vpce_gw_s3_name }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = data.terraform_remote_state.net_vpc.outputs.subnet.public_ids
      security_group_ids = [
        data.terraform_remote_state.net_sg.outputs.sg_internal.id,
        data.terraform_remote_state.net_sg.outputs.sg_storage.id,
        module.vpce_sg.security_group_id,
      ]
      tags = { Name = local.vpce_if_ssm_name }
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = data.terraform_remote_state.net_vpc.outputs.subnet.public_ids
      security_group_ids = [
        data.terraform_remote_state.net_sg.outputs.sg_internal.id,
        data.terraform_remote_state.net_sg.outputs.sg_storage.id,
        module.vpce_sg.security_group_id,
      ]
      tags = { Name = local.vpce_if_ssm_msg_name }
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = data.terraform_remote_state.net_vpc.outputs.subnet.public_ids
      security_group_ids = [
        data.terraform_remote_state.net_sg.outputs.sg_external.id,
        data.terraform_remote_state.net_sg.outputs.sg_internal.id,
        data.terraform_remote_state.net_sg.outputs.sg_storage.id,
        module.vpce_sg.security_group_id,
      ]
      tags = { Name = local.vpce_if_logs_name }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = data.terraform_remote_state.net_vpc.outputs.subnet.public_ids
      security_group_ids = [
        data.terraform_remote_state.net_sg.outputs.sg_internal.id,
        module.vpce_sg.security_group_id,
      ]
      tags = { Name = local.vpce_if_ecr_api_name }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = data.terraform_remote_state.net_vpc.outputs.subnet.public_ids
      security_group_ids = [
        data.terraform_remote_state.net_sg.outputs.sg_internal.id,
        module.vpce_sg.security_group_id,
      ]
      tags = { Name = local.vpce_if_ecr_dkr_name }
    },
  }
}


module "vpce_sg" {
  source = "terraform-aws-modules/security-group/aws"

  tags = {
    Managed_by = "Terragrunt"
    Env        = "sogaoh-spike"
  }

  name            = local.vpce_sg_name
  use_name_prefix = false
  description     = local.vpce_sg_description
  vpc_id          = data.terraform_remote_state.net_vpc.outputs.vpc.id

  ingress_cidr_blocks = [
    data.terraform_remote_state.net_vpc.outputs.vpc.cidr,
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = data.terraform_remote_state.net_vpc.outputs.vpc.cidr
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
    }
  ]
}
