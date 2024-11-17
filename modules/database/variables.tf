variable "vpc_id" {
  type = string
  description = "Database vpc id"
}

variable "sg" {
  type = any
  description = "Database vpc id"
}

variable "identifier" {
  type = string
  description = "Name of the database"
}

variable "engine" {
  type = string
  description = "Database engine"
}

variable "engine_version" {
  type = string
  description = "Database engine version"
}

variable "instance_class" {
  type = string
  description = "Database instance class"
}

variable "allocated_storage" {
  type = number
  description = "Database allocated storage"
}

variable "db_name" {
  type = string
  description = "Internal db name"
}

variable "username" {
  type = string
  description = "Database username"
}

variable "port" {
  type = string
  description = "Database port"
}

variable "maintenance_window" {
  type = string
  description = "Database maintenance window"
  default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type = string
  description = "Database backup window"
  default = "03:00-06:00"
}

variable "tags" {
  type = map(any)
  default = {}
}

variable "subnet_ids" {
  type = list(any)
  description = "Database subnet ids"
}

variable "family" {
  type = string
  default = "mysql5.7"
}

variable "major_engine_version" {
  type = string
  default = "5.7"
}

variable "delete_protection" {
  type = bool
  default = true
}

variable "parameters" {
  type = any
  default = [
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
