# Create IAM user
resource "aws_iam_user" "dev_view" {
  name = "bedrock-dev-view"
  tags = {
    Project = "karatu-2025-capstone"
  }
}

# Access keys for grading
resource "aws_iam_access_key" "dev_view" {
  user = aws_iam_user.dev_view.name
}

# Attach ReadOnlyAccess for AWS Console
resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Attach S3 PutObject for the specific bucket
resource "aws_iam_user_policy" "s3_put" {
  name = "bedrock-assets-put"
  user = aws_iam_user.dev_view.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.assets.arn}/*"
      },
    ]
  })
}

# Add IAM user to EKS via aws-auth (EKS access entries)
# Since EKS cluster_creator_admin_permissions is true and we use EKS 1.30, 
# access entries are preferred over aws-auth configmap.
resource "aws_eks_access_entry" "dev_view" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_user.dev_view.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "dev_view_policy" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_iam_user.dev_view.arn
  access_scope {
    type = "cluster"
  }
}
