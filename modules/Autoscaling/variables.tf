# lauch template
variable "project" {}
variable "image_id" {}
variable "key_name" {}
variable "sg" {}
variable "security_group" {}

#auto scaling
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "asg_health_check_type" {}
variable "lb_subnets" {}
variable "target_group_arns" {}




# variable "db_config" {
#   type = object(
#     {
#       user     = string
#       password = string
#       database = string
#       hostname = string
#       port     = string
#     }
#   )
# }
