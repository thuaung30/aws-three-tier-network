variable "name" {
  type = string
  description = "Name of the load balancer"
}

variable "sg" {
  type = any
  description = "Security group rules"
}

variable "vpc_id" {
  type  = string
  description = "VPC ID"
}

variable "public_subnets" {
  type = list(any)
  description = "Public subnet list for load balancer"
}

variable "tg_port" {
  type = number
  description = "Target group port"
}

variable "tg_protocol" {
  type = string 
  description = "Target group protocol"
}

variable "listener_port" {
  type = number
  description = "Listener port"
}
variable "listener_protocol" {
  type = string
  description = "Listener protocol"
}
