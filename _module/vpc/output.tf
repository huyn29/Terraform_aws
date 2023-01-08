output "public_sub" {
  value = [aws_subnet.public_subnet[0].id,aws_subnet.public_subnet[1].id,aws_subnet.public_subnet[2].id]
}
output "private_sub" {
  value = [aws_subnet.private_subnet[0].id,aws_subnet.private_subnet[1].id,aws_subnet.private_subnet[2].id]
}
output "hsg" {
  value = aws_security_group.huyn_sg.id
}
output "vpc_id" {
  value = aws_vpc.huyn_vpc.id
}