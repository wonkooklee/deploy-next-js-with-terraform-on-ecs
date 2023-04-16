# ECS Service
# Target Group
# Task Definition
# Load Balancer Listener Rule
# Load Balancer Zone Record

resource "aws_ecs_service" "wonkook_first_service" {
  name            = "wonkook-first-service-${var.subdomain}"
  cluster         = var.cluster
  task_definition = aws_ecs_task_definition.wonkook_task_def_2.family
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true # Providing our containers with public IPs
    # Setting the security group
    security_groups = var.security_groups
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wonkooklee_tg.arn
    container_name   = aws_ecs_task_definition.wonkook_task_def_2.family
    container_port   = 3000
  }

  tags = {
    "ENVIRONMENT" = var.env
    "MODULE" = "wk_ecs"
  }
}

resource "aws_lb_target_group" "wonkooklee_tg" {
  name        = var.target_group_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    matcher = "200,301,302"
    path    = "/api/health_check"
  }

  tags = {
    "ENVIRONMENT" = var.env
    "MODULE" = "wk_ecs"
  }
}

resource "aws_ecs_task_definition" "wonkook_task_def_2" {
  family = "wonkook-task-def-${var.subdomain}"

  container_definitions = jsonencode([
    {
      name      = "wonkook-task-def-${var.subdomain}"
      image     = "${var.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      memory = 512
      cpu    = 256
      environment = [
        {
          name = "NEXT_PUBLIC_DEPLOY_ENVIRONMENT"
          value = var.subdomain
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = var.execution_role_arn

  tags = {
    "ENVIRONMENT" = var.env
    "MODULE" = "wk_ecs"
  }
}

resource "aws_lb_listener_rule" "listener_rule_2" {
  listener_arn = var.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wonkooklee_tg.arn
  }

  condition {
    host_header {
      values = ["${var.subdomain}.wonkooklee.com"]
    }
  }

  tags = {
    "ENVIRONMENT" = var.env
    "MODULE" = "wk_ecs"
  }
}

resource "aws_route53_record" "dev" {
  zone_id = var.route53_zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.alias_alb_dns_name
    zone_id                = var.alias_alb_zone_id
    evaluate_target_health = true
  }
}