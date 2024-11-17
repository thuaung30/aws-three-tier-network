output "bastion_asg_arn" {
  value = resource.aws_autoscaling_group.bastion.arn
}

output "backend_asg_arn" {
  value = resource.aws_autoscaling_group.backend.arn
}
