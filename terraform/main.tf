resource "aws_ecr_repository" "wonkook_ecr_repo" {
  name                 = "wonkook-ecr-repo"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "wonkook_ecs_cluster" {
  name = "wonkook-ecs-cluster"
}

resource "aws_alb" "application_load_balancer" {
  name               = "wonkook-lb"
  load_balancer_type = "application"
  subnets            = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]

  # Referencing the Security Group
  security_groups = ["${aws_security_group.load_balancer_sg.id}"]
}

variable "web_ingress" {
  type = map(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = {
    "80" = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["110.12.2.0/24"]
    }
    "443" = {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["110.12.2.0/24"]
    }
  }
}

resource "aws_security_group" "load_balancer_sg" {
  name = "wonkook-sg"


  dynamic "ingress" {
    for_each = var.web_ingress
    content {
      description = "TLC from VPC"
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_security_group" "service_sg" {
  name = "wonkook-service-lb"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_lb_target_group" "wonkook_tg" {
#   name        = "wonkook-tg"
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = aws_default_vpc.aws_default_vpc.id

#   health_check {
#     matcher = "200,301,302"
#     path    = "/api/health_check"
#   }
# }

resource "aws_lb_listener" "wonkook_lb_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_certificate" "wonkook_lb_certificate" {
  listener_arn    = aws_lb_listener.wonkook_lb_listener.arn
  certificate_arn = var.certificate_arn
}

# resource "aws_lb_listener_rule" "listener_rule_1" {
#   listener_arn = aws_lb_listener.wonkook_lb_listener.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.wonkook_tg.arn
#   }

#   condition {
#     host_header {
#       values = ["staging.wonkooklee.com"]
#     }
#   }
# }

# resource "aws_lb_listener_rule" "listener_rule_2" {
#   listener_arn = aws_lb_listener.wonkook_lb_listener.arn
#   priority     = 90

#   action {
#     type             = "forward"
#     target_group_arn = module.ecs.target_group_arn_2
#   }

#   condition {
#     host_header {
#       values = ["dev.wonkooklee.com"]
#     }
#   }
# }

# resource "aws_ecs_task_definition" "wonkook_task_def" {
#   family = "wonkook-task-def"

#   container_definitions = jsonencode([
#     {
#       name      = "wonkook-task-def"
#       image     = "${aws_ecr_repository.wonkook_ecr_repo.repository_url}:${var.image_tag}"
#       essential = true
#       portMappings = [
#         {
#           containerPort = 3000
#           hostPort      = 3000
#         }
#       ]
#       memory = 512
#       cpu    = 256
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group         = "wonkook-container",
#           awslogs-region        = var.aws_region,
#           awslogs-create-group  = "true",
#           awslogs-stream-prefix = "wonkook"
#         }
#       }
#     }
#   ])
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   memory                   = 512
#   cpu                      = 256
#   execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
# }

# resource "aws_ecs_service" "wonkook_first_service" {
#   name            = "wonkook-first-service"
#   cluster         = aws_ecs_cluster.wonkook_ecs_cluster.id
#   task_definition = aws_ecs_task_definition.wonkook_task_def.family
#   launch_type     = "FARGATE"
#   desired_count   = 2

#   network_configuration {
#     subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
#     assign_public_ip = true # Providing our containers with public IPs
#     # Setting the security group
#     security_groups = [aws_security_group.service_sg.id]
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.wonkook_tg.arn
#     container_name   = aws_ecs_task_definition.wonkook_task_def.family
#     container_port   = 3000
#   }
# }

variable "ecs_module_parameters" {
  type = map(object({
    subdomain         = string
    target_group_name = string
    image_tag         = string
    priority          = optional(number)
  }))
  default = {
    "dev-1" = {
      image_tag         = "latest"
      subdomain         = "dev-1"
      target_group_name = "dev-1-tg"
    }
    "dev-2" = {
      image_tag         = "latest"
      subdomain         = "dev-2"
      target_group_name = "dev-2-tg"
    }
    "dev-3" = {
      image_tag         = "latest"
      subdomain         = "dev-3"
      target_group_name = "dev-3-tg"
    }
  }
}

module "ecs_dev" {
  source = "./module"

  subnets            = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
  vpc_id             = aws_default_vpc.aws_default_vpc.id
  cluster            = aws_ecs_cluster.wonkook_ecs_cluster.id
  lb_listener_arn    = aws_lb_listener.wonkook_lb_listener.arn
  alias_alb_dns_name = aws_alb.application_load_balancer.dns_name
  alias_alb_zone_id  = data.aws_lb_hosted_zone_id.main.id
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  repository_url     = aws_ecr_repository.wonkook_ecr_repo.repository_url
  security_groups    = [aws_security_group.service_sg.id]
  route53_zone_id    = var.my_route53_zone_id

  for_each          = var.depoly-to == "dev" ? tomap(var.ecs_module_parameters) : tomap({})
  subdomain         = each.value.subdomain
  target_group_name = each.value.target_group_name
  image_tag         = each.value.image_tag
  env               = each.key
}

module "ecs_staging" {
  count  = var.depoly-to == "staging" ? 1 : 0
  source = "./module"

  subnets            = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
  vpc_id             = aws_default_vpc.aws_default_vpc.id
  cluster            = aws_ecs_cluster.wonkook_ecs_cluster.id
  lb_listener_arn    = aws_lb_listener.wonkook_lb_listener.arn
  alias_alb_dns_name = aws_alb.application_load_balancer.dns_name
  alias_alb_zone_id  = data.aws_lb_hosted_zone_id.main.id
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  repository_url     = aws_ecr_repository.wonkook_ecr_repo.repository_url
  security_groups    = [aws_security_group.service_sg.id]
  route53_zone_id    = var.my_route53_zone_id

  subdomain         = "staging"
  target_group_name = "staging-tg"
  image_tag         = var.image_tag
  env               = "staging"
}

module "ecs_production" {
  count  = var.depoly-to == "production" ? 1 : 0
  source = "./module"

  subnets            = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
  vpc_id             = aws_default_vpc.aws_default_vpc.id
  cluster            = aws_ecs_cluster.wonkook_ecs_cluster.id
  lb_listener_arn    = aws_lb_listener.wonkook_lb_listener.arn
  alias_alb_dns_name = aws_alb.application_load_balancer.dns_name
  alias_alb_zone_id  = data.aws_lb_hosted_zone_id.main.id
  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  repository_url     = aws_ecr_repository.wonkook_ecr_repo.repository_url
  security_groups    = [aws_security_group.service_sg.id]
  route53_zone_id    = var.my_route53_zone_id

  subdomain         = "production"
  target_group_name = "production-tg"
  image_tag         = var.image_tag
  env               = "production"
}

# variable "subdomain" {
#   type = string
# }

# variable "target_group_name" {
#   type = string
# }
