# Local variable
locals {
  project = "demo"
}
# Networking
module "aws_vpc" {
  source         = "../modules/vpc"
  project        = local.project
  cidr_id        = "10.0.0.0/16"
  public_subnet  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  az_list        = ["us-east-1a", "us-east-1b", "us-east-1a", "us-east-1b"]

}
# load balancer
module "application_lb" {
  source             = "../modules/alb"
  project            = local.project
  load_balancer_type = "application"
  subnets            = [module.aws_vpc.public_sub[0], module.aws_vpc.public_sub[1]]
  lb_target_type     = "instance"
  vpc_id             = module.aws_vpc.vpc_id
  security_groups    = [module.aws_vpc.hsg]

}
# AMI
data "aws_ami" "ami_linux" {

  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# Autoscaling
module "auto_scaling" {
  source                = "../modules/Autoscaling"
  project               = local.project
  image_id              = data.aws_ami.ami_linux.id
  instance_type         = "t2.micro"
  key_name              = aws_key_pair.auth.id
  security_group        = [module.aws_vpc.hsg]
  max_size              = 3
  min_size              = 1
  desired_capacity      = 1
  asg_health_check_type = "ELB"
  lb_subnets            = [module.aws_vpc.private_sub[0], module.aws_vpc.private_sub[1]]
  target_group_arns     = [module.application_lb.lb_target_group_arn]

}
# get pem file
resource "tls_private_key" "huyn_key" {
  algorithm = "RSA"
}
resource "local_file" "save_key" {
  filename = "huyn.pem"
  content  = tls_private_key.huyn_key.private_key_pem
  # local_sensitive_file = tls_private_key.huyn_key.private_key_pem
  file_permission = "0400"
}
# key pair
resource "aws_key_pair" "auth" {
  key_name   = "huyn"
  public_key = tls_private_key.huyn_key.public_key_openssh
  # public_key = "${file("~/.ssh/id_rsa.pub")}"
  #ssh-keygen -f .ssh/id_rsa -e -m pem > ~/Desktop/huyn.pem
}
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ami_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = module.aws_vpc.public_sub[0]
  security_groups             = [module.aws_vpc.hsg]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.auth.id
  # provisioner "local-exec" {
  #   on_failure = fail #continue 
  #   command    = "echo ip: ${aws_instance.bastion.public_ip} > Bastion.txt"
  # }
  tags = {
    "Name" = "bastion"
  }
}
resource "local_file" "ip_intance1" {
  content  = aws_instance.bastion.public_ip
  filename = "key-ip/public_ip.txt"
}
# Database
module "rds_db" {
  source    = "../modules/rds"
  project   = local.project
  db_subnet = [module.aws_vpc.private_sub[2], module.aws_vpc.private_sub[3]]
  vpc_id    = module.aws_vpc.vpc_id
}
# resource "aws_instance" "instance1" {
#   ami                         = data.aws_ami.ami_linux.id
#   instance_type               = "t2.micro"
#   subnet_id                   = module.aws_vpc.private_sub[1]
#   security_groups             = [module.aws_vpc.hsg]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.auth.id
#   provisioner "local-exec" {
#     on_failure = fail #continue 
#     command    = "echo ip: ${aws_instance.instance1.public_ip} > public_ip.txt"
#   }
#   tags = {
#     "Name" = "huyn"
#   }
#   user_data = <<-EOF
#                 #!/bin/bash
#                 sudo yum update -y
#                 sudo yum install httpd -y
#                 sudo service httpd start
#                 sudo bash -c  "echo '<center><h1>I am huy</h1></center>' > /var/www/html/index.html"
#                 EOF
# }
# resource "null_resource" "execute" {
#   connection {
#     type = "ssh"
#     host = aws_instance.instance1.public_ip
#     user = "ec2-user"
#     private_key = "${file("~/.ssh/id_rsa")}"
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "echo huyn"
#     ]
#   }
#   depends_on = [
#     aws_instance.instance1
#   ]
# }

