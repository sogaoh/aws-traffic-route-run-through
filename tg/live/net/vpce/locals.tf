locals {
  //tf_store_bucket = "sogaoh-spike-tf-store"

  vpce_gw_s3_name      = "sogaoh-spike-s3-vpce"
  vpce_if_ssm_name     = "sogaoh-spike-ssm-vpce"
  vpce_if_ssm_msg_name = "sogaoh-spike-ssmmessages-vpce"
  vpce_if_logs_name    = "sogaoh-spike-logs-vpce"
  vpce_if_ecr_api_name = "sogaoh-spike-ecr-api-vpce"
  vpce_if_ecr_dkr_name = "sogaoh-spike-ecr-dkr-vpce"

  vpce_sg_name        = "sogaoh-spike-sg-vpce"
  vpce_sg_description = "sogaoh vpc endpoint SG (spike)"

  all_network_cidr = "0.0.0.0/0"
}

data "terraform_remote_state" "net_vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}
data "terraform_remote_state" "net_sg" {
  backend = "local"
  config = {
    path = "../sg/terraform.tfstate"
  }
}
