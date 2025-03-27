data "aws_secretsmanager_secret" "my_secret" {
  arn = "arn:aws:secretsmanager:ap-south-1:533267406282:secret:rds/kra/credentials-Cf86C4"
}

data "aws_secretsmanager_secret_version" "secret_ver" {
  secret_id = data.aws_secretsmanager_secret.my_secret.id
}

locals {
  rds_credentials = jsondecode(data.aws_secretsmanager_secret_version.secret_ver.secret_string)
}

resource "aws_db_instance" "postgresql" {
  allocated_storage       = var.allocated_storage
  storage_type            = "gp2"
  identifier              = var.identifier
  instance_class          = var.instance_class
  engine                  = "postgres"
  engine_version          = var.engine_version
  username                = local.rds_credentials["username"]
  password                = local.rds_credentials["password"]
  db_name                 = local.rds_credentials["database"]
  publicly_accessible     = var.publicly_accessible
  db_subnet_group_name    = aws_db_subnet_group.subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = true

  tags = {
    Name = "postgresql-db"
  }

  depends_on = [aws_db_subnet_group.subnet, aws_security_group.rds_sg]
}

resource "aws_db_subnet_group" "subnet" {
  name       = "subnet-grp"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "subnet-grp"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  vpc_id      = var.vpc_id
  description = "Security group for RDS DB instance."

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_security_group_rule" "rule-1" {
  security_group_id = aws_security_group.rds_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = ["103.199.191.127/32"]
}

resource "aws_security_group_rule" "rule-2" {
  security_group_id        = aws_security_group.rds_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = var.eks-sg-id
}

resource "aws_security_group_rule" "rule-3" {
  security_group_id = aws_security_group.rds_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

output "rds-sg-id" {
  value = aws_security_group.rds_sg.id
}