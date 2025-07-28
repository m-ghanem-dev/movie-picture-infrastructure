module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "movie-picture-eks-cluster"
  cluster_version = var.k8s_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  enable_irsa = true

  # Enable the AWS Load Balancer Controller Addon
  aws_load_balancer_controller = {
    enable = true
    version = "v2.7.0" # Or latest
    namespace = "kube-system"
    create_iam_role = true
  }

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
