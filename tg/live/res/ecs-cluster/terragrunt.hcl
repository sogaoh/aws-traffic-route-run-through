dependency "ecr" {
  config_path = "../ecr"
}

dependency "ecs_task_exec_role" {
  config_path = "../../manage/task-exec-role"
}

inputs = {
  ecr_repository_url = dependency.ecr.outputs.ecr_repository_urls[0]
  ecs_task_execution_role_arn = dependency.ecs_task_exec_role.outputs.ecs_task_exec_role_arn
}
