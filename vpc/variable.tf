variable "name_vpc" {
  type = string
}
variable "vpc_cidr" {
  type = string
  description = "Cidr for vpc"
  default = "10.0.0.0/16"
}
variable "subnet_list" {
  type = list
  description = "list subnet"
  default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
}
variable "az_list" {
  type = list
  description = "list az"
  default = ["us-east-1a","us-east-1b","us-east-1c"]
}