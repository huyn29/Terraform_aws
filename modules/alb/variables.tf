variable "lb_name" {
  description = "name for load balancer"
  type        = string
}
variable "load_balancer_type" {
  description = "Application or Network type LB"
  type        = string
}
variable "security_groups" {
  description = "sg for load balancer"
}
variable "subnets" {
  description = "LB subnets"
  type        = list(string)
  default     = []
}

variable "lb_target_type" {
  description = "Target type ip (ALB/NLB), instance (Autosaling group)"
  type        = string
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
  default     = null
}
variable "instance_id" {}

