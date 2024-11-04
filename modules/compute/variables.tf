variable "ssh_key" {
    type = string
    description = "SSH key name"
}

variable "vpc_id" {
    type = string
    description = "VPC ID"
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
