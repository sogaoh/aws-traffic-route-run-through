local envs = import './variables/envs.libsonnet';
local secrets = import './variables/secrets.libsonnet';
[
  {
    name: '{{ must_env `ECS_SERVICE_NAME` }}',
    image: '{{ must_env `ECR_REPOSITORY_URI` }}',
    environment: envs,
    secrets: secrets,
    essential: true,
    readonlyRootFilesystem: false,
    logConfiguration: {
      logDriver: 'awslogs',
      options: {
        'awslogs-group': '{{ ecs_tfstate `module.ecs_exec_log_group.aws_cloudwatch_log_group.this[0].name` }}',
        'awslogs-region': '{{ must_env `AWS_DEFAULT_REGION` }}',
        'awslogs-stream-prefix': '{{ must_env `ECS_SERVICE_NAME` }}',
      },
    },
    startTimeout: 300,
    stopTimeout: 120,
    volumesFrom: [],
    pseudoTerminal: true
  },
]