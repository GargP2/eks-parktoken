resource "aws_eks_node_group" "prod" {
  cluster_name    = local.cluster_name
  node_group_name = "prod"
  subnet_ids      = module.vpc.private_subnets
  node_role_arn   = aws_iam_role.prod.arn

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.prod-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.prod-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.prod-AmazonEC2ContainerRegistryReadOnly,
  ]

}

resource "aws_iam_role" "prod" {
  name = "eks-node-group-prod"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "prod-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.prod.name
}

resource "aws_iam_role_policy_attachment" "prod-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.prod.name
}

resource "aws_iam_role_policy_attachment" "prod-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.prod.name
}
