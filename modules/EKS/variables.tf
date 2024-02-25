# Environment
variable "env" {
  type = string
  description = "Environment"
  default = "Dev"
}

# Type
variable "type" {
  type = string
  description = "Type"
  default = "backend"
}

# Stack name
variable "cluster_name" {
  type = string
  description = "Project Name"
  default = "EKS"
}

# Public subnet AZ1
variable "public_subnet_az1_id" {
  type = string
  description = "ID of Public Subnet in AZ1"
}

# Public subnet AZ2
variable "public_subnet_az2_id" {
  type = string
  description = "ID of Public Subnet in AZ2"
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
  default = "Terraform"
}

# Worker Node & Kubectl instance size
variable "instance_size" {
  type = string
  description = "Worker node's instance size"
  default = "t2.micro"
}

# node count
variable "worker_node_count" {
  type = string
  description = "Worker node's count"
  default = "2"
}
