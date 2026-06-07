output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = var.region
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "assets_bucket_name" {
  value = aws_s3_bucket.assets.bucket
}

output "dev_view_access_key" {
  value = aws_iam_access_key.dev_view.id
}

output "dev_view_secret_key" {
  value     = aws_iam_access_key.dev_view.secret
  sensitive = true
}

output "dev_view_password" {
  value     = aws_iam_user_login_profile.dev_view.password
  sensitive = true
}

output "alb_url" {
  value = "Check AWS EC2 Load Balancers console for the classic load balancer URL"
}
