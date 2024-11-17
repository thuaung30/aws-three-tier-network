terraform {
  required_version = ">= 1.9.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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
    Terraform   = "true"
    Environment = "dev"
  }

}

module "loadbalancer" {
  source = "./modules/loadbalancing"

  name           = "aws-networking-loadbalancer"
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets

  sg = {
    name = "lb_sg"
    ingress = [
      {
        description = "http"
        cidr_ipv4   = "0.0.0.0/0"
        from_port   = 80
        ip_protocol = "http"
        to_port     = 80
      }
    ]
    egress = [
      {
        description = "egress allow all"
        cidr_ipv4   = "0.0.0.0/0"
        ip_protocol = "-1"
      }
    ]
  }

  tg_port     = 80
  tg_protocol = "HTTP"

  listener_port     = 80
  listener_protocol = "HTTP"
}

module "compute" {
  source = "./modules/compute"

  ssh_key = "proton"

  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = slice(module.network.private_subnets, 0, 2) # Only take the first two private subnets

  lb_tg_arn  = module.loadbalancer.tg_arn
  lb_tg_name = module.loadbalancer.tg_name

  bastion = {
    name          = "bastion"
    instance_type = "t2.micro"
    ami_id        = "ami-04b6019d38ea93034" # Amazon Linux 2023 AMI

    sg = {
      name = "bastion_sg"
      ingress = [
        {
          description = "ssh"
          cidr_ipv4   = "54.151.193.188/32"
          from_port   = 22
          ip_protocol = "tcp"
          to_port     = 22
        }
      ]
      egress = [
        {
          description = "egress allow all"
          cidr_ipv4   = "0.0.0.0/0"
          ip_protocol = "-1"
        }
      ]
    }

    min_size         = 1
    max_size         = 1
    desired_capacity = 1
    tags             = {}
  }

  backend = {
    name          = "backend"
    instance_type = "t2.micro"
    ami_id        = "ami-04b6019d38ea93034" # Amazon Linux 2023 AMI

    sg = {
      name = "backend_sg"
      ingress = [
        {
          description = "ssh"
          cidr_ipv4   = "10.200.0.0/16"
          from_port   = 22
          ip_protocol = "tcp"
          to_port     = 22
        },
        {
          description = "http"
          cidr_ipv4   = "10.200.0.0/16"
          from_port   = 80
          ip_protocol = "http"
          to_port     = 80
        }
      ]
      egress = [
        {
          description = "egress allow all"
          cidr_ipv4   = "0.0.0.0/0"
          ip_protocol = "-1"
        }
      ]
    }

    min_size         = 2
    max_size         = 2
    desired_capacity = 2
    tags             = {}
  }
}


module "database" {
  source = "./modules/database"

  vpc_id = module.network.vpc_id

  sg = {
    name = "db_sg"
    ingress = [
      {
        description = "http"
        cidr_ipv4   = "10.200.0.0/16"
        from_port   = 3306
        ip_protocol = "mysql"
        to_port     = 3306
      }
    ]
    egress = [
      {
        description = "egress allow all"
        cidr_ipv4   = "0.0.0.0/0"
        ip_protocol = "-1"
      }
    ]
  }

  identifier        = "aws-networking-db"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3a.large"
  allocated_storage = 5

  db_name  = "foodb"
  username = "foo"
  port     = "3306"

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  subnet_ids = slice(module.network.private_subnets, 2, 4)

  family = "mysql5.7"

  major_engine_version = "5.7"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}
