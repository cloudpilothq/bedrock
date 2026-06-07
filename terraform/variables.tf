variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "project-bedrock-cluster"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "project-bedrock-vpc"
}

variable "student_id" {
  description = "Student ID for S3 bucket uniqueness"
  type        = string
  default     = "alt-soe-025-4492"
}

variable "app_namespace" {
  description = "Namespace for the retail app"
  type        = string
  default     = "retail-app"
}
