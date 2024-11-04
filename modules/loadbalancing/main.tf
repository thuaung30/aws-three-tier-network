# SECURITY GROUP FOR BASTION LAUNCH TEMPLATE
resource "aws_security_group" "this" {
  name        = try(var.name, "lb")
  description = "Allow inbound traffic for loadbalancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = try(var.sg.name, "backend_sg")
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

# INTERNET FACING LOAD BALANCER
resource "aws_lb" "this" {
  name            = var.name
  security_groups = [aws_security_group.this.id]
  subnets         = var.public_subnets
  idle_timeout    = 400
}

resource "aws_lb_target_group" "this" {
  name     = var.name
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
