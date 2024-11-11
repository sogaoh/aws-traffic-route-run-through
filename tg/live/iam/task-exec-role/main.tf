module "ecs_task_exec_role" {
  source = "../../../tf-modules/ecs-task-exec"

  env_identifier          = var.env_identifier
  ecs_task_exec_role_name = "sogaoh-${var.env_identifier}-bastionEcsTaskExecRole"
}
