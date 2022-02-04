# //////////////////////////////
# LOAD BALANCER RESOURCES
# //////////////////////////////
resource "aws_lb" "quest" {
  name               = "alb"
  subnets            = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

  tags = {
    Environment = "test"
    Application = "quest"
  }
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.quest.arn
  port              = "443"
  protocol          = "HTTPS"
  depends_on        = [aws_lb_target_group.quest]
  certificate_arn   = data.aws_acm_certificate.issued.arn
  #port     = 80
  #protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.quest.arn
  }
}

resource "aws_lb_target_group" "quest" {
  name_prefix = "quest"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default_vpc.id
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}