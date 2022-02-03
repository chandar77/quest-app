TERRAFORM TO CREATE ECS CLUSTER with FARGATE, ALB , SECURITY GROUP, TLS.

PREREQUISITES
DOCKER IMAGE, VPC, SUBNETS, SSL CERTS AND IAM POLICIES 

USE CASE 
These  terraform files create ECS task defitions, ECS Service, 2 FARGATE instances each on 2 subnets in different AZ's in a VPC. ALB target groups points to ECS tasks. 
Docker image from ECR has been referenced.
Self signed SSL certs are used.