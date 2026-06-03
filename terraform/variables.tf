variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "project-bedrock-vpc"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "project-bedrock-cluster"
}

variable "student_id" {
  description = "Student ID or unique suffix for S3 bucket"
  type        = string
  default     = "alt-soe-025-4492"
}
