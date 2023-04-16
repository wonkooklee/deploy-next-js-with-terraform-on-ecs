data "aws_lb_hosted_zone_id" "main" {}

# resource "aws_route53_record" "dev" {
#   zone_id
#   name    = "dev"
#   type    = "A"

#   alias {
#     name                   = aws_alb.application_load_balancer.dns_name
#     zone_id                = data.aws_lb_hosted_zone_id.main.id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "staging" {
#   zone_id
#   name    = "staging"
#   type    = "A"

#   alias {
#     name                   = aws_alb.application_load_balancer.dns_name
#     zone_id                = data.aws_lb_hosted_zone_id.main.id
#     evaluate_target_health = true
#   }
# }
