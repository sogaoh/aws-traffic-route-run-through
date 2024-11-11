generate "terraform_version" {
  path      = ".terraform-version"
  if_exists = "overwrite_terragrunt"
  contents  = "1.9.8"
}

generate "terragrunt_version" {
  path      = ".terragrunt-version"
  if_exists = "overwrite_terragrunt"
  contents  = "0.68.7"
}

generate "backend" {
  path      = "_backend.tf"
  if_exists = "skip"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
}
EOF
}

generate "provider" {
  path      = "_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = var.region
  profile = var.profile

  shared_credentials_files = ["~/.aws/credentials"]
}
EOF
}

generate "variables" {
  path      = "_variables.tf"
  if_exists = "skip"
  contents  = <<EOF
variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "profile" {
  type    = string
  default = ""
}
EOF
}

# generate "provider" {
#   path      = "_provider.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
# provider "aws" {
#   region  = var.region
#   profile = var.profile
#
#   shared_credentials_files = ["~/.aws/credentials"]
#
#   # 効かない
#   default_tags {
#     Managed_by  = "Terragrunt"
#   }
# }
# EOF
# }
