output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = "us-east-1"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "assets_bucket_name" {
  value = aws_s3_bucket.assets.bucket
}

# Output developer credentials for grading
output "dev_view_access_key" {
  value = aws_iam_access_key.dev_view.id
}

output "dev_view_secret_key" {
  value = aws_iam_access_key.dev_view.secret
  sensitive = true
}
