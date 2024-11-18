# aws-traffic-route-run-through

NAT Gateway と VPC Endpoint を経由した通信を発生させるサンプル環境


## 構成概要

- VPC
    - Public Subnet
    - Private Subnet
    - NAT Gateway
    - VPC Endpoint (Fargate用に Interface型 いくつか)
- S3
- ECS Cluster
    - Fargate bastion
    - ECR
