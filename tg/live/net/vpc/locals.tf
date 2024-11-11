locals {
  vpc_name = "sogaoh-spike-vpc"
  vpc_cidr = "172.29.0.0/16"
  vpc_azs  = ["ap-northeast-1a", "ap-northeast-1d"]

  pub_subnet_cidr = ["172.29.0.0/20", "172.29.16.0/20"]  // 4,091 IP can use
  pri_subnet_cidr = ["172.29.80.0/20", "172.29.96.0/20"] // 4,091 IP can use
  //db_subnet_cidr  = ["172.29.160.0/20", "172.29.176.0/20"] // 4,091 IP can use
}
