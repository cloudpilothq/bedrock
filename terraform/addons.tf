module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true

  eks_addons = {
    amazon-cloudwatch-observability = {
      addon_version = "v1.8.0"
      preserve      = true
      most_recent   = false
    }
    vpc-cni = {
      addon_version = "v1.14.1-eksbuild.1"
      preserve      = true
      most_recent   = false
    }
    kube-proxy = {
      addon_version = "v1.30.0-eksbuild.1"
      preserve      = true
      most_recent   = false
    }
    coredns = {
      addon_version = "v1.10.1-eksbuild.1"
      preserve      = true
      most_recent   = false
    }
  }

  depends_on = [module.eks]
}
