/////////////////////////////////////////////
# data sources to get values for various resources
////////////////////////////////////////////
data "aws_ecr_repository" "quest" {
  name = "quest_test"
}
data "aws_acm_certificate" "issued" {
  domain = "alb-1131884962.us-east-1.elb.amazonaws.com"
}
data "aws_iam_role" "default" {
  name = "ecsTaskExecutionRole"
}