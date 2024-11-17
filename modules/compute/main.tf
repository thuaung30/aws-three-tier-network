locals {
  default_ami_id = "ami-04b6019d38ea93034"
  default_instance_type = "t2.micro"
}

data "aws_lb_target_group" "this" {
  arn  = var.lb_tg_arn
  name  = var.lb_tg_name
}

# SSH KEY FOR BASTION HOST
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.ssh_key
  public_key = tls_private_key.main.public_key_openssh
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${var.ssh_key}.pem"
  file_permission = "0400"
}

# SECURITY GROUP FOR BASTION LAUNCH TEMPLATE
resource "aws_security_group" "bastion" {
  name        = try(var.bastion.sg.name, "bastion_sg")
  description = "Allow inbound traffic bastion hosts"
  vpc_id      = var.vpc_id

  tags = {
    Name = try(var.bastion.sg.name, "bastion_sg")
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion" {
  for_each = { for ingress in var.bastion.sg.ingress: ingress.description => ingress }

  security_group_id = aws_security_group.bastion.id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = try(each.value.from_port, null)
  ip_protocol       = each.value.ip_protocol
  to_port           = try(each.value.to_port, null)
}

resource "aws_vpc_security_group_egress_rule" "bastion" {
  for_each = { for egress in var.bastion.sg.egress: egress.description => egress }

  security_group_id = aws_security_group.bastion.id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = try(each.value.from_port, null)
  ip_protocol       = each.value.ip_protocol
  to_port           = try(each.value.to_port, null)
}

# LAUNCH TEMPLATE AND AUTOSCALING GROUP FOR BASTION HOST
resource "aws_launch_template" "bastion" {
  name_prefix            = try(var.bastion.name, "bastion")
  instance_type          = try(var.bastion.instance_type, local.default_instance_type)
  image_id               = try(var.bastion.ami_id, local.default_ami_id) 
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.ssh_key

  tags = merge(var.bastion.tags,{
    Name = "bastion"
  })
}

resource "aws_autoscaling_group" "bastion" {
  name                = try(var.bastion.name, "bastion")
  vpc_zone_identifier = var.public_subnets
  min_size            = try(var.bastion.min_size, 0)
  max_size            = try(var.bastion.max_size, 0)
  desired_capacity    = try(var.bastion.desired_capacity, 0)

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }
}

# SECURITY GROUP FOR BASTION LAUNCH TEMPLATE
resource "aws_security_group" "backend" {
  name        = try(var.backend.sg.name, "backend_sg")
  description = "Allow inbound traffic backend hosts"
  vpc_id      = var.vpc_id

  tags = {
    Name = try(var.backend.sg.name, "backend_sg")
  }
}

resource "aws_vpc_security_group_ingress_rule" "backend" {
  for_each = { for ingress in var.backend.sg.ingress: ingress.description => ingress }

  security_group_id = aws_security_group.backend.id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = try(each.value.from_port, null)
  ip_protocol       = each.value.ip_protocol
  to_port           = try(each.value.to_port, null)
}

resource "aws_vpc_security_group_egress_rule" "backend" {
  for_each = { for egress in var.backend.sg.egress: egress.description => egress }

  security_group_id = aws_security_group.backend.id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = try(each.value.from_port, null)
  ip_protocol       = each.value.ip_protocol
  to_port           = try(each.value.to_port, null)
}

# LAUNCH TEMPLATE AND AUTOSCALING GROUP FOR BACKEND
resource "aws_launch_template" "backend" {
  name_prefix            = try(var.backend.name, "backend")
  instance_type          = try(var.backend.instance_type, local.default_instance_type)
  image_id               = try(var.backend.ami_id, local.default_ami_id)
  vpc_security_group_ids = [aws_security_group.backend.id]
  key_name               = var.ssh_key
  user_data              = filebase64("scripts/bootstrap.sh")

  tags = merge(var.backend.tags, {
    Name = "backend"
  })
}

resource "aws_autoscaling_group" "backend" {
  name                = try(var.backend.name, "backend")
  vpc_zone_identifier = var.private_subnets
  min_size            = try(var.backend.min_size, 0)
  max_size            = try(var.backend.max_size, 0)
  desired_capacity    = try(var.backend.desired_capacity, 0)

  target_group_arns = [data.aws_lb_target_group.this.arn]

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
}

# AUTOSCALING ATTACHMENT FOR APP TIER TO LOADBALANCER
/*
resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.backend.id
  lb_target_group_arn    = var.lb_tg
}
*/
