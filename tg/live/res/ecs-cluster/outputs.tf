output "ecs_cluster" {
  value = {
    name = module.ecs_cluster.cluster_name
    arn  = module.ecs_cluster.cluster_arn
  }
}

output "ecs_exec_log_group" {
  value = {
    name = module.ecs_exec_log_group.cloudwatch_log_group_name
    arn  = module.ecs_exec_log_group.cloudwatch_log_group_arn
  }
}
