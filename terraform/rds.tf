resource "aws_db_subnet_group" "default" {
  name       = "project-bedrock-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "project-bedrock-db-sg"
  description = "Allow DB traffic from EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_db_instance" "catalog_db" {
  identifier             = "project-bedrock-catalog-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "catalog"
  username               = "catalogadmin"
  password               = "SuperSecretPassword123!"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_db_instance" "orders_db" {
  identifier             = "project-bedrock-orders-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  db_name                = "orders"
  username               = "ordersadmin"
  password               = "SuperSecretPassword123!"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = {
    Project = "karatu-2025-capstone"
  }
}

resource "aws_secretsmanager_secret" "catalog_db_secret" {
  name                    = "project-bedrock/catalog-db"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "catalog_db_secret_version" {
  secret_id = aws_secretsmanager_secret.catalog_db_secret.id
  secret_string = jsonencode({
    username = aws_db_instance.catalog_db.username
    password = aws_db_instance.catalog_db.password
  })
}

resource "aws_secretsmanager_secret" "orders_db_secret" {
  name                    = "project-bedrock/orders-db"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "orders_db_secret_version" {
  secret_id = aws_secretsmanager_secret.orders_db_secret.id
  secret_string = jsonencode({
    username = aws_db_instance.orders_db.username
    password = aws_db_instance.orders_db.password
  })
}
