# REGION
variable "AWS_REGION" {
  type = string
  default = "us-east-1"
}
# Environment
variable "env" {
  type = string
  default = "Dev"
}
# Type
variable "type" {
  type = string
  default = "backend"
}

# Stack name
variable "cluster_name" {
  type = string
  default ="EKS"
}

# VPC CIDR
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# CIDR of public subet in AZ1 
variable "public_subnet_az1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

# CIDR of public subet in AZ2
variable "public_subnet_az2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}
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
}

# Stack name
variable "cluster_name" {
  type = string
}

# SSH Access
variable "ssh_access" {
  type = list(string)
}

# UI Access
variable "http_access" {
  type = list(string)
}
# Environment
variable "env" {
  type = string
  description = "Environment"
}

# Type
variable "type" {
  type = string
  description = "Type"
}

# Stack name
variable "cluster_name" {
  type = string
  description = "Project Name"
}

# Public subnet AZ1
variable "public_subnet_az1_id" {
  type = string
  description = "ID of Public Subnet in AZ1"
  default = "10.0.1.0/24"
}

# Public subnet AZ2
variable "public_subnet_az2_id" {
  type = string
  description = "ID of Public Subnet in AZ2"
  default = "10.0.2.0/24"
}

# Security Group 
variable "eks_security_group_id" {
  type = string
  description = "ID of EKS worker node's security group"
}

# Master ARN
variable "master_arn" {
  type = string
  description = "ARN of master node"
}

# Worker ARN
variable "worker_arn" {
  type = string
  description = "ARN of worker node"
}

# Key name
variable "key_name" {
  type = string
  description = "Name of SSH key"
}

# Worker Node & Kubectl instance size
variable "instance_size" {
  type = string
  description = "Worker node's instance size"
}

# node count
variable "worker_node_count" {
  type = string
  description = "Worker node's count"
}
