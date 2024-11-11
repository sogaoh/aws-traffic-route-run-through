locals {
  //tf_store_bucket = "sogaoh-spike-tf-store"

  external_sg_name        = "sogaoh-spike-sg-external"
  external_sg_description = "sogaoh external SG (spike)"

  internal_sg_name        = "sogaoh-spike-sg-internal"
  internal_sg_description = "sogaoh internal SG (spike)"

  storage_sg_name        = "sogaoh-spike-sg-storage"
  storage_sg_description = "sogaoh storage SG (spike)"

  all_network_cidr = "0.0.0.0/0"
}

data "terraform_remote_state" "net_vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}
