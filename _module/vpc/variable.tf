variable "cidr_id" {
  type = string
  description = "cidr for vpc"
}
variable "public_subnet" {
  type = list(string)
}
variable "private_subnet" {
  type = list(string)
}
variable "az_list" {
  type = list(string)
}