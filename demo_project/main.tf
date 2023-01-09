module "huyn_vpc" {
  source = "../_module/vpc"
  cidr_id = "10.0.0.0/16"
  public_subnet = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  private_subnet = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]
  az_list = ["us-east-1a","us-east-1b","us-east-1c"]
}
data "aws_ami" "ami_linux" {

	most_recent = true
    owners = ["amazon"]
	filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
	}
	filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
resource "tls_private_key" "huyn_key" {
  algorithm = "RSA"
}
resource "local_file" "save_key" {
  filename = "huyn.pem"
  content = tls_private_key.huyn_key.private_key_pem
  # local_sensitive_file = tls_private_key.huyn_key.private_key_pem
  file_permission = "0400"
}
resource "aws_key_pair" "auth" {
  key_name = "huyn"
  public_key = tls_private_key.huyn_key.public_key_openssh
  # public_key = "${file("~/.ssh/id_rsa.pub")}"
  #ssh-keygen -f .ssh/id_rsa -e -m pem > ~/Desktop/huyn.pem
}
resource "aws_instance" "instance1" {
  ami = data.aws_ami.ami_linux.id
  instance_type = "t2.micro"
  subnet_id = module.huyn_vpc.private_sub[1]
  security_groups = [module.huyn_vpc.hsg]
  associate_public_ip_address = true
  key_name = aws_key_pair.auth.id
  provisioner "local-exec" {
    on_failure = fail #continue 
    command = "echo ip: ${aws_instance.instance1.public_ip} > public_ip.txt"
  }
  tags = {
    "Name" = "huyn"
  }
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install httpd -y
                sudo service httpd start
                sudo bash -c  "echo '<center><h1>I am huy</h1></center>' > /var/www/html/index.html"
                EOF
}
module "application_lb" {
  source                     = "../_module/elb"
  subnets                    = [module.huyn_vpc.private_sub[0],module.huyn_vpc.private_sub[1],module.huyn_vpc.private_sub[2]]
  vpc_id = module.huyn_vpc.vpc_id
  security_groups = [module.huyn_vpc.hsg]
  instance_id = aws_instance.instance1.id
}
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
# resource "aws_instance" "instance2" {
#   ami = data.aws_ami.ami_linux.id
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.huyn_subnet[0].id
#   vpc_security_group_ids = [aws_security_group.huyn_sg.id]
#   associate_public_ip_address = true
#   key_name = aws_key_pair.auth.id
#   tags = {
#     "Name" = "control_machine"
#   }
# }
# resource "aws_instance" "instance3" {
#   ami = data.aws_ami.ami_linux.id
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.huyn_subnet[0].id
#   vpc_security_group_ids = [aws_security_group.huyn_sg.id]
#   associate_public_ip_address = true
#   key_name = aws_key_pair.auth.id
#   tags = {
#     "Name" = "target_machine"
#   }
# }
# resource "local_file" "ip_intance1" { 
#   content =  aws_instance.instance1.public_ip
#   filename = "key_ip/jenkins.txt"
# }
# resource "local_file" "ip_intance2" { 
#   content =  aws_instance.instance2.public_ip
#   filename = "key_ip/control.txt"
# }
# resource "local_file" "ip_intance3" { 
#   content =  aws_instance.instance3.public_ip
#   filename = "key_ip/target.txt"
# }