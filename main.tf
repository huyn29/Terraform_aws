module "huyn_vpc" {
  source = "./vpc"
  name_vpc = "huyn29_vpc"
}
# create intances
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
resource "aws_key_pair" "auth" {
  key_name = "huyn"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
  #ssh-keygen -f .ssh/id_rsa -e -m pem > ~/Desktop/huyn.pem
}
resource "aws_instance" "instance1" {
  ami = data.aws_ami.ami_linux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.huyn_subnet[0].id
  vpc_security_group_ids = [aws_security_group.huyn_sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.auth.id
  tags = {
    "Name" = "jenkins_machine"
  }
}
resource "aws_instance" "instance2" {
  ami = data.aws_ami.ami_linux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.huyn_subnet[0].id
  vpc_security_group_ids = [aws_security_group.huyn_sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.auth.id
  tags = {
    "Name" = "control_machine"
  }
}
resource "aws_instance" "instance3" {
  ami = data.aws_ami.ami_linux.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.huyn_subnet[0].id
  vpc_security_group_ids = [aws_security_group.huyn_sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.auth.id
  tags = {
    "Name" = "target_machine"
  }
}
resource "local_file" "ip_intance1" { 
  content =  aws_instance.instance1.public_ip
  filename = "key_ip/jenkins.txt"
}
resource "local_file" "ip_intance2" { 
  content =  aws_instance.instance2.public_ip
  filename = "key_ip/control.txt"
}
resource "local_file" "ip_intance3" { 
  content =  aws_instance.instance3.public_ip
  filename = "key_ip/target.txt"
}