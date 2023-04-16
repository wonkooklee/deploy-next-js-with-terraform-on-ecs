variable "aws_region" {
  default     = "ap-northeast-2"
  description = "Defining a default AWS infrastructure region"
}

# Will be retrieved from .tfvars file.
variable "ecsTaskExecutionRole_policy_arn" {
  type    = string
  default = ""
}

variable "cloudWatchLogGroupCreation_policy_arn" {
  type    = string
  default = ""
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "my_route53_zone_id" {
  type    = string
  default = ""
}

variable "backend_bucket_name" {
  type    = string
  default = ""
}

variable "image_tag" {
  type = string
  validation {
    condition     = can(regex("^((v[1-9]{1}\\.\\d{1,2}\\.\\d{1,3})|latest)$", var.image_tag))
    error_message = "Invalid semantic version syntax.(e.g. v1.2.4)"
  }
  default = "latest"
}

variable "depoly-to" {
  type = string
}

variable "aws_ecr_repository_url" {
  type = string
}

# locals {
#   security-groups = jsondecode(file("${path.module}/SecurityGroup.json"))["Domain"]["SecurityGroups"]
# }

# variable "test_security_groups" {
#   type = map(object({
#     ingress_port        = number
#     ingress_protocol    = string
#     ingress_cidr_blocks = list(string)
#     egress_port         = number
#     egress_protocol     = string
#     egress_cidr_blocks  = list(string)
#     tags                = string
#   }))
# }

# resource "aws_security_group" "ecs_security_groups" {
#   vpc_id = aws_default_vpc.aws_default_vpc.id

#   for_each = local.security-groups
#   name     = each.value["sg_name"]

#   ingress {
#     from_port   = each.value["sg_ingress_port"]
#     to_port     = each.value["sg_ingress_port"]
#     protocol    = each.value["sg_ingress_protocol"]
#     cidr_blocks = each.value["sg_ingress_cidr_blocks"]
#   }

#   egress {
#     from_port   = each.value["sg_egress_port"]
#     to_port     = each.value["sg_egress_port"]
#     protocol    = each.value["sg_egress_protocol"]
#     cidr_blocks = each.value["sg_egress_cidr_blocks"]
#   }

#   tags = each.value["sg_tags"]
# }
