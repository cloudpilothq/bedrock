resource "helm_release" "retail_app" {
  name             = "retail-app"
  chart            = "${path.module}/../kubernetes/src/app/chart"
  namespace        = var.app_namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/../kubernetes/custom-values.yaml.tpl", {
      catalog_db_endpoint = aws_db_instance.catalog_db.endpoint
      catalog_db_password = aws_db_instance.catalog_db.password
      orders_db_endpoint  = aws_db_instance.orders_db.endpoint
      orders_db_password  = aws_db_instance.orders_db.password
      carts_table_name    = aws_dynamodb_table.carts.name
    })
  ]

  depends_on = [
    module.eks,
    aws_db_instance.catalog_db,
    aws_db_instance.orders_db,
    aws_dynamodb_table.carts
  ]
}

