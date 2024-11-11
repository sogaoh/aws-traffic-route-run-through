local containerDefinitions = import 'libsonnet/taskdef/containerDefinitions.libsonnet';
{
  cpu: "256",
  memory: "512",
  taskRoleArn: '{{ taskRole_tfstate `module.ecs_task_exec_role.aws_iam_role.ecs_task_exec_role.arn` }}',
  executionRoleArn: '{{ taskRole_tfstate `module.ecs_task_exec_role.aws_iam_role.ecs_task_exec_role.arn` }}',
  family: '{{ must_env `ECS_CLUSTER_NAME` }}_{{ must_env `ECS_SERVICE_NAME` }}',
  networkMode: 'awsvpc',
  requiresCompatibilities: ['FARGATE'],
  runtimePlatform: {
    operatingSystemFamily: 'LINUX',
    cpuArchitecture: 'ARM64',
  },
  volumes: [],
  containerDefinitions: containerDefinitions,
}
