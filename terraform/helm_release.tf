resource "kubernetes_namespace" "retail_app" {
  metadata {
    name = "retail-app"
  }
}

resource "helm_release" "retail_store" {
  name       = "retail-store"
  repository = "oci://public.ecr.aws/aws-containers"
  chart      = "retail-store-sample-app"


  namespace = kubernetes_namespace.retail_app.metadata[0].name

  # Overriding the UI service to use LoadBalancer with AWS ALB Ingress Controller
  set {
    name  = "ui.ingress.enabled"
    value = "true"
  }
  set {
    name  = "ui.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "alb"
  }
  set {
    name  = "ui.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internet-facing"
  }
  set {
    name  = "ui.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
    value = "ip"
  }

  # Override Catalog (MySQL)
  set {
    name  = "catalog.mysql.enabled"
    value = "false"
  }
  set {
    name  = "catalog.env.DB_HOST"
    value = aws_db_instance.mysql.address
  }
  set {
    name  = "catalog.env.DB_USER"
    value = aws_db_instance.mysql.username
  }
  set {
    name  = "catalog.env.DB_PASSWORD"
    value = aws_db_instance.mysql.password
  }

  # Override Orders (Postgres)
  set {
    name  = "orders.postgres.enabled"
    value = "false"
  }
  set {
    name  = "orders.env.DB_HOST"
    value = aws_db_instance.postgres.address
  }
  set {
    name  = "orders.env.DB_USER"
    value = aws_db_instance.postgres.username
  }
  set {
    name  = "orders.env.DB_PASSWORD"
    value = aws_db_instance.postgres.password
  }

  # Override Carts (DynamoDB)
  set {
    name  = "carts.dynamodb.enabled"
    value = "true" # The app might have an internal dynamodb toggle, or we just pass the table name
  }
  set {
    name  = "carts.env.DYNAMODB_TABLE_NAME"
    value = aws_dynamodb_table.carts.name
  }

  depends_on = [
    module.eks_blueprints_addons,
    aws_db_instance.mysql,
    aws_db_instance.postgres,
    aws_dynamodb_table.carts
  ]
}
