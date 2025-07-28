locals {
  eks_cluster_name = "movie-picture-eks-cluster"
}

# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"
  
  # VPC Basic Details
  name = local.eks_cluster_name
  cidr = "10.0.0.0/16"  # corrected from `cidr_block`
  azs  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]  # must be a list

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  # NAT Gateways - Outbound Communication
  enable_nat_gateway = true
  single_nat_gateway = true

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
    "kubernetes.io/role/elb" = 1    
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"        
  }
  private_subnet_tags = {
    Type = "private-subnets"
    "kubernetes.io/role/internal-elb" = 1    
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"    
  }

  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true  
}
