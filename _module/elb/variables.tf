
variable "security_groups" {

}

variable "load_balancer_type" {
  description = "Application or Network type LB"
  type        = string
  default     = "application"
}

variable "subnets" {
  description = "LB subnets"
  type        = list(string)
  default     = []
}

variable "enable_deletion_protection" {
  description = "enable_deletion_protection true or false"
  type        = bool
  default     = false
}


variable "lb_target_port" {
  description = "lb_target_port 80 or 443"
  type        = number
  default     = 80
}

variable "lb_protocol" {
  description = "lb_protocol HTTP (ALB) or TCP (NLB)"
  type        = string
  default     = "HTTP"
}

variable "lb_target_type" {
  description = "Target type ip (ALB/NLB), instance (Autosaling group)"
  type        = string
  default     = "ip"
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
  default     = null
}

