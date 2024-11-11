variable "ecr_repositories" {
  type = list(string)
  default = [
    "sogaoh-bastion",
  ]
}

