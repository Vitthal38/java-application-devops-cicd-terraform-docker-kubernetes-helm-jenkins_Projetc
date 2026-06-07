provider "aws" {
  region = var.region
}

# ──────────────────────────────────────────────
# DynamoDB table for Terraform state locking.
# Prevents two concurrent `terraform apply` runs
# from corrupting the shared state file.
# ──────────────────────────────────────────────
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.common_tags
}

# ──────────────────────────────────────────────
# VPC
# ──────────────────────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs            = var.availability_zones
  public_subnets = var.public_subnet_cidrs

  # Required by AWS Load Balancer Controller to discover which
  # subnets to place ALBs in.
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  enable_nat_gateway      = false
  single_nat_gateway      = false
  map_public_ip_on_launch = true

  tags = var.common_tags
}

# ──────────────────────────────────────────────
# EKS Cluster
# ──────────────────────────────────────────────
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"

      desired_size = var.node_desired_size
      min_size     = var.node_min_size
      max_size     = var.node_max_size

      labels = {
        Environment = var.environment
        Project     = var.project_name
      }

      tags = var.common_tags
    }
  }

  tags = var.common_tags
}
