output "dns_name" {
  value = aws_lb.this.dns_name
}

output "tg_name" {
  value = aws_lb_target_group.this.name
}

output "tg" {
  value = aws_lb_target_group.this.arn
}
