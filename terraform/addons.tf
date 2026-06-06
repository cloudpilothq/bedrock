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
      most_recent = true
      preserve    = true
    }
    vpc-cni = {
      most_recent = true
      preserve    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    kube-proxy = {
      most_recent = true
      preserve    = true
    }
    coredns = {
      most_recent = true
      preserve    = true
    }
  }

  depends_on = [module.eks]
}
