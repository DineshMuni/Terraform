# VPC ID
variable "vpc_id" {
  type = string
}

# Environment
variable "env" {
  type = string
  default = "Dev"
}

# Type
variable "type" {
  type = string
  default = "Dev"
}

# Stack name
variable "cluster_name" {
  type = string
  default = "EKS"
}

# SSH Access
variable "ssh_access" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

# UI Access
variable "http_access" {
  type = list(string)
  default = ["0.0.0.0/0"]
}
