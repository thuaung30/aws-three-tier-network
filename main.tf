terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.74.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

module "network" {
  source = "./modules/network"

  name = "aws-networking-vpc"
  cidr = "10.200.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets  = ["10.200.1.0/24", "10.200.2.0/24"]
  private_subnets = ["10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/24", "10.200.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }

}

module "compute" {
  source = "./modules/compute"

  ssh_key = "proton"

  vpc_id = module.network.vpc_id
  public_subnets = module.network.public_subnets
  private_subnets = slice(module.network.private_subnets, 0, 2) # Only take the first two private subnets

  bastion = {
    name = "bastion"
    instance_type = "t2.micro"
    ami_id = "ami-04b6019d38ea93034" # Amazon Linux 2023 AMI

    sg = {
      name = "bastion_sg"
      ingress = [
        {
          description = "ssh"
          cidr_ipv4 = "54.151.193.188/32"
          from_port = 22
          ip_protocol = "tcp"
          to_port = 22
        }
      ]
      egress = [
        {
          description = "egress allow all"
          cidr_ipv4 = "0.0.0.0/0"
          ip_protocol = "-1"
        }
      ]
    }

    min_size = 1
    max_size = 1
    desired_capacity = 1
    tags = {}
  }

  backend = {
    name = "backend"
    instance_type = "t2.micro"
    ami_id = "ami-04b6019d38ea93034" # Amazon Linux 2023 AMI

    sg = {
      name = "backend_sg"
      ingress = [
        {
          description = "ssh"
          cidr_ipv4 = "10.200.0.0/16"
          from_port = 22
          ip_protocol = "tcp"
          to_port = 22
        },
        {
          description = "http"
          cidr_ipv4 = "10.200.0.0/16"
          from_port = 80
          ip_protocol = "http"
          to_port = 80
        }
      ]
      egress = [
        {
          description = "egress allow all"
          cidr_ipv4 = "0.0.0.0/0"
          ip_protocol = "-1"
        }
      ]
    }

    min_size = 2
    max_size = 2
    desired_capacity = 2
    tags = {}
  }
}

module "loadbalancer" {
  source = "./modules/loadbalancing"

  name = "aws-networking-loadbalancer"
  vpc_id = module.network.vpc_id
  public_subnets = module.network.public_subnets

  sg = {
    name = "lb_sg"
    ingress = [
      {
        description = "http"
        cidr_ipv4 = "0.0.0.0/0"
        from_port = 80
        ip_protocol = "http"
        to_port = 80
      }
    ]
    egress = [
      {
        description = "egress allow all"
        cidr_ipv4 = "0.0.0.0/0"
        ip_protocol = "-1"
      }
    ]
  }

  tg_port = 80
  tg_protocol = "HTTP"

  listener_port = 80
  listener_protocol = "HTTP"
}
