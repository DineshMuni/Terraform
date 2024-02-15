provider "aws" {
    region = "${var.AWS_REGION}"
}

# Creating VPC

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-vpc"
    Env  = var.env
    Type = var.type
  }
}

# Creating Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "eks_internet_gateway" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.cluster_name}-igw"
    Env  = var.env
    Type = var.type
  }
}

# Using data source to get all Avalablility Zones in region
data "aws_availability_zones" "available_zones" {}

# Creating Public Subnet AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet AZ1"
    Env  = var.env
    Type = var.type
  }
}

# Creating Public Subnet AZ2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet AZ2"
    Env  = var.env
    Type = var.type
  }
}

# Creating Route Table and add Public Route
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_internet_gateway.id
  }

  tags = {
    Name = "Public Route Table"
    Env  = var.env
    Type = var.type
  }
}

# Associating Public Subnet in AZ1 to route table
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associating Public Subnet in AZ2 to route table
resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group for the EKS  
resource "aws_security_group" "eks_security_group" {
  name   = "SH security group"
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_access
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.http_access
  }

  ingress {
    description = "HTTPS port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.http_access
  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-EKS-security-group"
    Env  = var.env
    Type = var.type
  }
}

# Creating IAM role for Master Node
resource "aws_iam_role" "master" {
  name = "EKS-Master"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.master.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.master.name
}

# Creating IAM role for Worker Node
resource "aws_iam_role" "worker" {
  name = "ed-eks-worker"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Creating IAM Policy for auto-scaler
resource "aws_iam_policy" "autoscaler" {
  name = "ed-eks-autoscaler-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "x-ray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.worker.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.worker.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_instance_profile" "worker" {
  depends_on = [aws_iam_role.worker]
  name       = "EKS-worker-node-profile"
  role       = aws_iam_role.worker.name
}
# Creating EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "AWS-EKS"
  role_arn = var.master_arn

  vpc_config {
    subnet_ids = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  }

  tags = {
    key   = var.env
    value = var.type
  }
}

# Using Data Source to get all Avalablility Zones in Region
data "aws_availability_zones" "available_zones" {}

# Fetching Ubuntu 20.04 AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Creating kubectl server
resource "aws_instance" "kubectl-server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  key_name                    = var.key_name
  instance_type               = var.instance_size
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_az1_id
  vpc_security_group_ids      = [var.eks_security_group_id]

  tags = {
    Name = "${var.cluster_name}-kubectl"
    Env  = var.env
    Type = var.type
  }
}

# Creating Worker Node Group
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "Worker-Node-Group"
  node_role_arn   = var.worker_arn
  subnet_ids      = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = [var.instance_size]

  remote_access {
    ec2_ssh_key               = var.key_name
    source_security_group_ids = [var.eks_security_group_id]
  }

  labels = {
    env = "Prod"
  }

  scaling_config {
    desired_size = var.worker_node_count
    max_size     = var.worker_node_count
    min_size     = var.worker_node_count
  }

  update_config {
    max_unavailable = 1
  }
}






