variable "project" {}
variable "cidr_id" {}
variable "public_subnet" {
  type = list(string)
}
variable "private_subnet" {
  type = list(string)
}
variable "az_list" {
  type = list(string)
}
