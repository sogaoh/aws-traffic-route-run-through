output "ecr_repository_urls" {
  value = values({ for repo in module.private_registries : repo.repository_arn => repo.repository_url })
}
