variable "vpc_id" {
  type = string
}

variable "cluster" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "target_group_name" {
  type = string
}

variable "repository_url" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "subdomain" {
  type = string
}

variable "lb_listener_arn" {
  type = string
}

variable "alias_alb_dns_name" {
  type = string
}

variable "alias_alb_zone_id" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "env" {
  type = string
}
