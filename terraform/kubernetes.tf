module "load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.load_balancer_controller_irsa.iam_role_arn
  }

  depends_on = [
    module.eks,
    module.load_balancer_controller_irsa
  ]
}

resource "kubernetes_namespace" "retail_app" {
  metadata {
    name = "retail-app"
  }

  depends_on = [module.eks]
}

# External Secrets Operator (optional but good for passing RDS credentials)
# Or we can just use kubernetes_secret in terraform for simplicity

resource "kubernetes_secret" "catalog_db" {
  metadata {
    name      = "catalog-db"
    namespace = kubernetes_namespace.retail_app.metadata[0].name
  }

  data = {
    password = random_password.catalog_db_password.result
  }

  depends_on = [kubernetes_namespace.retail_app]
}

resource "kubernetes_secret" "orders_db" {
  metadata {
    name      = "orders-db"
    namespace = kubernetes_namespace.retail_app.metadata[0].name
  }

  data = {
    password = random_password.orders_db_password.result
  }

  depends_on = [kubernetes_namespace.retail_app]
}
