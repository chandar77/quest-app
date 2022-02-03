# //////////////////////////////
# VARIABLES
# //////////////////////////////


variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name"
  default     = "quest"
}

variable "task_family" {
  default = "quest"
}

variable "quest_service" {
  default = "quest-service"
}