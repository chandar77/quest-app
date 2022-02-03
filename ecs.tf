# //////////////////////////////////////
# ECS CLUSTER, TASK DEFINITION , FARGATE
# //////////////////////////////////////
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.task_family
  container_definitions    = <<EOF
[
  {
    "name": "quest-task",
    "image": "191155221734.dkr.ecr.us-east-1.amazonaws.com/quest_test:latest",
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
EOF
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 1024
  cpu                      = 512
  execution_role_arn       = "arn:aws:iam::191155221734:role/ecsTaskExecutionRole"
}

resource "aws_ecs_service" "quest_service" {
  name            = var.quest_service
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.quest.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.quest.arn
    container_name   = "quest-task"
    container_port   = 3000
  }

  #depends_on = [aws_lb_listener.https_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = {
    Environment = "test"
    Application = "quest-app"
  }
  desired_count = 2
}

resource "aws_default_vpc" "default_vpc" {

}
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}




