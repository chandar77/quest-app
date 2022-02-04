## Prereq for the project.
- Terraform v1.1.2 
- Docker cli
- aws cli
- AWS account

## Deploy first to find the secret word.
- Deploy the app on any cloud instance(used ec2) and find the secret word.

## Docker
- Download the app files locally to a directory, to limit the number of layers in the image. 
- Copy the Dockerfile to same dir to build the image.
- Build docker image and push to ECR using awscli

## Note 
- The permissions I have on the AWS account used for this task, doesn't allow me to craete few resources like vpc, subnet and IAM policies. So I have used data sources to reference and use the existing ones.

## Prerequsites for deploying with Terraform 
- VPC and Subnet
- ECR repo
- Create self signed certs and upload using aws cli

## Terraform Files included creates
-  Creating ECS CLUSTER with FARGATE.
-  Create ECS task defitions, ECS Service, 2 tasks created each on 2 subnets in different AZ's in a region. 
-  Create a log group to log the image logs as it's not done by default for the ECS tasks.
-  Target tracking scaling policies based on CPU and memory utilization.
-  ALB target groups points to 2 ECS tasks as we have the desired count set to 2.
-  Security groups.
-  Add TLS cert to ALB.

## Possible Improvements
- Building and uploading docker image is done locally and pushed with awscli.At a production level,this can be automated with a good CI/CD pipeline that can build the image, push it to a repo and scan the image on the repo. Personally used Artifactory and jenkins for these tasks previously.
- SSL certs are uploaded using awscli. As it is not a best practise to add SSL certs from terraform or use self signed certs. Ideally SSL certs from a provider should be added or request cert from AWS for your registered domain.
- The design takes High Availability and Auto scaling into consideration. But for latency CDN can be used.
- Best practices for terraform can be used. Can create custom resuable modules.
- Local tf backend was used. Terraform cloud or s3 backends would be ideal.