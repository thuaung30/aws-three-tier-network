module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = try(var.enable_nat_gateway, true)
  single_nat_gateway = try(var.single_nat_gateway, true)

  tags = var.tags
}
