resource "helm_release" "retail_app" {
  name       = "retail-store"
  chart      = "${path.module}/../helm-chart/app/chart"
  namespace  = kubernetes_namespace.retail_app.metadata[0].name

  values = [
    templatefile("${path.module}/../production-values.yaml", {})
  ]

  set {
    name  = "catalog.app.persistence.endpoint"
    value = aws_db_instance.catalog_mysql.endpoint
  }

  set {
    name  = "orders.app.persistence.endpoint"
    value = aws_db_instance.orders_postgres.endpoint
  }

  set {
    name  = "cart.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cart_irsa.iam_role_arn
  }

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer_controller,
    kubernetes_secret.catalog_db,
    kubernetes_secret.orders_db,
    aws_db_instance.catalog_mysql,
    aws_db_instance.orders_postgres,
    aws_dynamodb_table.cart_items
  ]
}
