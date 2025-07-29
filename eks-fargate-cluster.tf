module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "movie-picture-eks-cluster"
  cluster_version = var.k8s_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  enable_irsa = true
  enable_cluster_creator_admin_permissions= true

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  fargate_profiles = {
    default = {
      name = "fargate-default"
      selectors = [{ namespace = "default" }]
      subnet_ids = module.vpc.private_subnets
    }

    kube_system = {
      name = "fargate-kube-system"
      selectors = [{ namespace = "kube-system" }]
      subnet_ids = module.vpc.private_subnets
    }
  }
}

