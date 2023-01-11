resource "aws_db_subnet_group" "name" {
  name       = var.db_subnet
  subnet_ids = var.subnet_id
  tags = {
    "Name" = "DB subnet group"
  }
}
resource "aws_db_instance" "database" {
  allocated_storage      = 20
  engine                 = "postgresql"
  engine_version         = "12.7"
  instance_class         = "db.t2.micro"
  identifier             = "${var.project}-db-instance"
  name                   = "terraform"
  username               = "admin"
  password               = "admin"
  db_subnet_group_name   = var.vpc.database_subnet_group
  vpc_security_group_ids = [var.db_sg]
  skip_final_snapshot    = true
}
