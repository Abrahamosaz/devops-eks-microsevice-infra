
###############################################
#POSTGRES
###############################################
resource "aws_db_instance" "postgres_instance" {
  allocated_storage    = var.rds_allocated_storage
  db_name              = var.postgres_db_name
  engine               = "postgres"
  engine_version       = var.postgres_instance_engine_version
  instance_class       = var.postgres_instance_instance_class
  username             = var.postgres_instance_username
  password             = var.postgres_instance_password
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  vpc_security_group_ids  = [aws_security_group.postgres_security_group.id]
}

###############################################
#POSTGRES SECURITY GROUP
###############################################
resource "aws_security_group" "postgres_security_group" {
  name        = "${var.env}-postgres_security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id


  tags = {
    Name = "${var.env}-postgres_security_group"
  }
}


resource "aws_security_group_rule" "postgres_security_rule" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.postgres_security_group.id
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.postgres_security_group.id
}