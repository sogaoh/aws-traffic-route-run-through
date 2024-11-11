module "private_registries" {
  source = "terraform-aws-modules/ecr/aws"
  #version = "~> 2.2"

  for_each = toset(var.ecr_repositories)

  repository_name = each.value

  repository_image_tag_mutability = "MUTABLE"
  repository_image_scan_on_push   = true
  repository_encryption_type      = "AES256"

  create_repository_policy = true

  repository_lifecycle_policy = jsonencode({
    rules = [
      local.ecr_lifecycle_policy_untagged,
    ]
  })
}
