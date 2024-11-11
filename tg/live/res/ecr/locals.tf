locals {
  ecr_lifecycle_policy_untagged = {
    rulePriority = 99,
    description  = "Hold only 1 untagged image",
    selection = {
      tagStatus   = "untagged",
      countType   = "imageCountMoreThan",
      countNumber = 1
    },
    action = {
      type = "expire"
    }
  }
}
