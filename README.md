# aws-traffic-route-run-through

NAT Gateway と VPC Endpoint を経由した通信を発生させるサンプル環境


## 構成概要

- VPC
    - Public Subnet
    - Private Subnet
    - NAT Gateway
    - VPC Endpoint (S3・Gateway型)
- S3
- ECS Cluster
    - Fargate bastion
    - ECR
