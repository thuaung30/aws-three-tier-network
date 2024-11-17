locals {
  db_sg_default =  "db_sg"
}

# SECURITY GROUP FOR BASTION LAUNCH TEMPLATE
resource "aws_security_group" "this" {
  name        = try(var.sg.name, local.db_sg_default)
  description = "Allow inbound traffic database"
  vpc_id      = var.vpc_id

  tags = {
    Name = try(var.sg.name, local.db_sg_default)
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for ingress in var.sg.ingress: ingress.description => ingress }

  security_group_id = aws_security_group.this.id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = try(each.value.from_port, null)
  ip_protocol       = each.value.ip_protocol
  to_port           = try(each.value.to_port, null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for egress in var.sg.egress: egress.description => egress }

  security_group_id = aws_security_group.this.id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = try(each.value.from_port, null)
  ip_protocol       = each.value.ip_protocol
  to_port           = try(each.value.to_port, null)
}

module "this" {
  source = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier = var.identifier

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.username
  port     = var.port

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.this.id]

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  tags = var.tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids

  # DB parameter group
  family = var.family

  # DB option group
  major_engine_version = var.major_engine_version

  # Database Deletion Protection
  deletion_protection = var.delete_protection

  parameters = var.parameters
}
