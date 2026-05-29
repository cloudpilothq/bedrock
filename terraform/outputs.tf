output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "Assets S3 Bucket Name"
  value       = aws_s3_bucket.assets.id
}

output "dev_view_access_key" {
  description = "Access key for bedrock-dev-view user"
  value       = aws_iam_access_key.dev_view.id
}

output "dev_view_secret_key" {
  description = "Secret key for bedrock-dev-view user"
  value       = aws_iam_access_key.dev_view.secret
  sensitive   = true
}

output "dev_view_console_password" {
  description = "Console password for bedrock-dev-view user"
  value       = aws_iam_user_login_profile.dev_view.password
  sensitive   = true
}
