# Security Group for Databases
resource "aws_security_group" "db_sg" {
  name        = "project-bedrock-db-sg"
  description = "Security group for RDS databases"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow MySQL from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  ingress {
    description     = "Allow PostgreSQL from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "project-bedrock-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

# MySQL for Catalog
resource "random_password" "catalog_db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "catalog_mysql" {
  identifier           = "bedrock-catalog-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "catalog"
  username             = "catalog_user"
  password             = random_password.catalog_db_password.result
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
}

resource "aws_secretsmanager_secret" "catalog_db_secret" {
  name                    = "bedrock/catalog-db"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "catalog_db_secret_val" {
  secret_id     = aws_secretsmanager_secret.catalog_db_secret.id
  secret_string = random_password.catalog_db_password.result
}

# PostgreSQL for Orders
resource "random_password" "orders_db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "orders_postgres" {
  identifier           = "bedrock-orders-postgres"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "orders"
  username             = "orders_user"
  password             = random_password.orders_db_password.result
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
}

resource "aws_secretsmanager_secret" "orders_db_secret" {
  name                    = "bedrock/orders-db"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "orders_db_secret_val" {
  secret_id     = aws_secretsmanager_secret.orders_db_secret.id
  secret_string = random_password.orders_db_password.result
}

# DynamoDB for Cart
resource "aws_dynamodb_table" "cart_items" {
  name         = "Items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  # Cart service uses 'id' as hash key (sometimes 'customerId' depending on version).
  # We'll define 'id' and 'customerId' and create a GSI if needed.
  # Let's inspect the cart service or use a generic setup.

  attribute {
    name = "id"
    type = "S"
  }
  
  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name               = "customerId-index"
    hash_key           = "customerId"
    projection_type    = "ALL"
  }
}

# Create IAM role for Cart Service Account to access DynamoDB
module "cart_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name = "bedrock-cart-dynamodb-role"

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["retail-app:carts"]
    }
  }
}
