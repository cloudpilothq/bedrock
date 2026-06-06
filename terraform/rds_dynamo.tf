# Security Group for Databases
resource "aws_security_group" "db_sg" {
  name        = "bedrock-db-sg"
  description = "Allow EKS nodes to access databases"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "bedrock-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

# MySQL (e.g. for Catalog)
resource "random_password" "mysql_pw" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "mysql_secret" {
  name = "bedrock-mysql-credentials"
}

resource "aws_secretsmanager_secret_version" "mysql_secret_version" {
  secret_id     = aws_secretsmanager_secret.mysql_secret.id
  secret_string = jsonencode({
    username = "mysqluser"
    password = random_password.mysql_pw.result
  })
}

resource "aws_db_instance" "mysql" {
  identifier           = "bedrock-mysql"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "catalog"
  username             = "mysqluser"
  password             = random_password.mysql_pw.result
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
}

# PostgreSQL (e.g. for Orders)
resource "random_password" "pg_pw" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "pg_secret" {
  name = "bedrock-pg-credentials"
}

resource "aws_secretsmanager_secret_version" "pg_secret_version" {
  secret_id     = aws_secretsmanager_secret.pg_secret.id
  secret_string = jsonencode({
    username = "postgres"
    password = random_password.pg_pw.result
  })
}

resource "aws_db_instance" "postgres" {
  identifier           = "bedrock-postgres"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  db_name              = "orders"
  username             = "postgres"
  password             = random_password.pg_pw.result
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
}

# DynamoDB for Carts
resource "aws_dynamodb_table" "carts" {
  name           = "bedrock-carts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
