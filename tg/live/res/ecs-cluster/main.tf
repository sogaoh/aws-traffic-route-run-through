module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"
  #version = "5.11"

  cluster_name = local.ecs_cluster_name

  create_cloudwatch_log_group            = false
  cloudwatch_log_group_retention_in_days = 3

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = local.ecs_exec_logs_name
      }
    }
  }

  cluster_settings = {
    "name" : "containerInsights"
    "value" : local.container_insights_state
  }

  fargate_capacity_providers = {
    FARGATE = {
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }
}

module "ecs_exec_log_group" {
  source = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  #version = "~> 5.5"

  name              = local.ecs_exec_logs_name
  retention_in_days = 2
}
