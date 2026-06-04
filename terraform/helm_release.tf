# Deploy AWS Load Balancer Controller to handle Ingress
module "load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name                              = "load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
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
  wait       = false

  set = [
    {
      name  = "clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.load_balancer_controller_irsa.iam_role_arn
    }
  ]

  depends_on = [module.eks]
}

# Deploy the InnovateMart Retail Store Sample App
resource "helm_release" "retail_store" {
  name             = "retail-store"
  repository       = "oci://public.ecr.aws/aws-containers"
  chart            = "retail-store-sample-chart"
  namespace        = "retail-app"
  create_namespace = true
  wait             = false

  # Override with external RDS databases and DynamoDB
  set = [
    {
      name  = "catalog.database.endpoint"
      value = aws_db_instance.catalog.endpoint
    },
    {
      name  = "catalog.database.username"
      value = aws_db_instance.catalog.username
    },
    {
      name  = "catalog.database.password"
      value = aws_db_instance.catalog.password
    },
    {
      name  = "orders.database.endpoint"
      value = aws_db_instance.orders.endpoint
    },
    {
      name  = "orders.database.username"
      value = aws_db_instance.orders.username
    },
    {
      name  = "orders.database.password"
      value = aws_db_instance.orders.password
    },
    {
      name  = "cart.dynamodb.tableName"
      value = aws_dynamodb_table.cart.name
    },
    {
      name  = "cart.app.persistence.provider"
      value = "dynamodb"
    },
    {
      name  = "cart.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.cart_irsa.iam_role_arn
    },
    {
      name  = "ui.service.type"
      value = "LoadBalancer"
    }
  ]

  depends_on = [
    helm_release.aws_load_balancer_controller,
    aws_db_instance.catalog,
    aws_db_instance.orders,
    aws_dynamodb_table.cart
  ]
}
