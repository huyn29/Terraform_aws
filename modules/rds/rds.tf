resource "aws_db_instance" "this" {
  instance_class          = "db.t2.micro"
  engine                  = "mysql"
  engine_version          = "5.7"
  multi_az                = true
  storage_type            = "gp2"
  allocated_storage       = 20
  db_name                 = "${var.project}-db"
  username                = "admin"
  password                = "admin"
  apply_immediately       = "true"
  backup_retention_period = 10
  # backup_window           = "09:46-10:16"
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-db-sg"
  subnet_ids = var.db_subnet
}

resource "aws_security_group" "this" {
  name   = "${var.project}-db-sg"
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    "Name" = "${var.project}-db-sg"
  }
}

/*
data "aws_kms_secret" "rds" {
  secret {
    name = "db-password"
    payload = "AQICAHibS2rwth4UleeAxsSEfxgwqkPtD0jzkRM/Ez91Y7cbvwEHP2YRcuplZp/H7GqmIuXVAAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMps5PwT/x3nCnBMfTAgEQgCNd+Y6q9KBZbIX8JZlqP7EDErQLuaBLh6mKaYBz+5blxWstwQ=="
  }
}
*/
