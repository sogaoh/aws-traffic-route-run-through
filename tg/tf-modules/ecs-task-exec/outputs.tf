output "ecs_task_exec_role_arn" {
  description = "ARN of the ECS Task Exec IAM role"
  value       = aws_iam_role.ecs_task_exec_role.arn
}