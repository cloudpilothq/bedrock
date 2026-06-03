# Create the IAM user for developers
resource "aws_iam_user" "dev_view" {
  name = "bedrock-dev-view"
}

# Attach a basic managed policy (optional, but good for base AWS console access)
resource "aws_iam_user_policy_attachment" "dev_view_readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# EKS Access Entry to grant Kubernetes cluster access to the IAM user
resource "aws_eks_access_entry" "dev_view_entry" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_user.dev_view.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "dev_view_policy" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_iam_user.dev_view.arn
  access_scope {
    type       = "cluster"
  }
}
