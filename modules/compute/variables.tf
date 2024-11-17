variable "ssh_key" {
    type = string
    description = "SSH key name"
}

variable "vpc_id" {
    type = string
    description = "VPC ID"
}

variable "lb_tg_arn" {
    description = "Loadbalancer target group arn"
    type = string
}

variable "lb_tg_name" {
    description = "Loadbalancer target group arn"
    type = string
}


variable "bastion" {
    type = any
    description = "Settings for bastion host"
}

variable "backend" {
    type = any
    description = "Settings for bastion host"
}

variable "public_subnets" {
    type = list(any)
    description = "Public subnets"
}

variable "private_subnets" {
    type = list(any)
    description = "private subnets"
}
