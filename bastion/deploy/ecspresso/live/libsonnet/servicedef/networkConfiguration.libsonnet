{
  awsvpcConfiguration: {
    assignPublicIp: 'ENABLED',
    securityGroups: [
      '{{ must_env `ECS_SECURITY_GROUP_ID` }}',
    ],
    subnets: [
      '{{ must_env `ECS_SUBNET_A_ID` }}',
      '{{ must_env `ECS_SUBNET_D_ID` }}',
    ]
  },
}
