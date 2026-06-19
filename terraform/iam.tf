resource "aws_iam_user" "dev_view" {
  name          = "bedrock-dev-view"
  force_destroy = true
}

resource "aws_iam_access_key" "dev_view" {
  user = aws_iam_user.dev_view.name
}

resource "aws_iam_user_login_profile" "dev_view" {
  user                    = aws_iam_user.dev_view.name
  password_reset_required = false
}

resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy" "s3_put" {
  name = "S3PutObjectAssets"
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

# Grant EKS access via Access Entry API
resource "aws_eks_access_entry" "dev_view" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_user.dev_view.arn
  kubernetes_groups = ["view"]
  type              = "STANDARD"
}



resource "kubernetes_cluster_role_binding" "dev_view" {
  depends_on = [module.eks]
  metadata {
    name = "bedrock-dev-view-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = "view"
    api_group = "rbac.authorization.k8s.io"
  }
}
