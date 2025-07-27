
#########################################
# EKS Fargate Profile and Execution Role
#########################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fargate-default"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = [aws_subnet.private.id]

  selector {
    namespace = "default"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.fargate_execution_policy
  ]
}

resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fargate-kube-system"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = [aws_subnet.private.id]

  selector {
    namespace = "kube-system"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.fargate_execution_policy
  ]
}


# Create the fargate pod execution role.
# Roles consists of a trust policy and a permissions policy

resource "aws_iam_role" "fargate_pod_execution_role" {
  name = "fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_execution_policy" {
  role       = aws_iam_role.fargate_pod_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}