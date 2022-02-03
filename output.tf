# //////////////////////////////
# OUTPUT
# //////////////////////////////
output "quest_dns" {
  value       = aws_lb.quest.id
  description = "DNS name of the AWS ALB"
}