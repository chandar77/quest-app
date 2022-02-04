# /////////////////////////////////////////////////////
# ECS CLUSTER, TASK DEFINITION , FARGATE, AUTO SCALING
# /////////////////////////////////////////////////////

# create ecs cluster 

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# Errors in ECS tasks are not captured by default. Creating a log group to capture container logs. 

resource "aws_cloudwatch_log_group" "quest" {
  name = "quest_logs"
}
resource "aws_ecs_task_definition" "task" {
  family                   = var.task_family
  container_definitions    = <<EOF
[
  {
    "name": "quest-task",
    "image": "${data.aws_ecr_repository.quest.repository_url}:latest",
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.quest.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ecs-quest"
        }
      },
    "portMappings": [
      {
        "containerPort": 3000,
        "protocol"      : "tcp",
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
  execution_role_arn       = data.aws_iam_role.default.arn

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
  #ignore_changes = [desired_count]
  #depends_on = [aws_lb_listener.https_forward]

  tags = {
    Environment = "test"
    Application = "quest-app"
  }
  desired_count = 2
}

# referencing the vpc and subnet for ecs service

resource "aws_default_vpc" "default_vpc" {

}
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

# autoscaling for ECS tasks based on target tracking CPU and memory.

resource "aws_appautoscaling_target" "quest" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.quest_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  #role_arn           = "arn:aws:iam::191155221734:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
}

resource "aws_appautoscaling_policy" "quest_memory" {
  name               = "quest-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.quest.resource_id
  scalable_dimension = aws_appautoscaling_target.quest.scalable_dimension
  service_namespace  = aws_appautoscaling_target.quest.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 85
  }
}

resource "aws_appautoscaling_policy" "quest_cpu" {
  name               = "quest-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.quest.resource_id
  scalable_dimension = aws_appautoscaling_target.quest.scalable_dimension
  service_namespace  = aws_appautoscaling_target.quest.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 75
  }
}

