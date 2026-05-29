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

resource "aws_iam_user_policy_attachment" "dev_view_ro" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy" "dev_view_s3" {
  name = "s3-put-object-assets"
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

resource "aws_eks_access_entry" "dev_view" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_user.dev_view.arn
  kubernetes_groups = ["view-group"]
  type              = "STANDARD"
}

resource "kubernetes_cluster_role_binding" "dev_view" {
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
    name      = "view-group"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [module.eks]
}
