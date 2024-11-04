variable "name" {
  type        = string
  description = "VPC name"
}

variable "cidr" {
  type        = string
  description = "CIDR range"
}

variable "azs" {
  type        = list(any)
  description = "AZ list"
}

variable "public_subnets" {
  type        = list(any)
  description = "Public subnet list"
}

variable "private_subnets" {
  type        = list(any)
  description = "Public subnet list"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Single NAT Gateway"
  default     = true
}

variable "tags" {
  type        = map(any)
  description = "Tags"
  default     = {}
}
