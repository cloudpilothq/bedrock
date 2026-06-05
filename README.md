# Project Bedrock - InnovateMart EKS Deployment

This repository contains the Infrastructure as Code (IaC) and deployment configurations for the InnovateMart Retail Store Application, codenamed "Project Bedrock".

## Infrastructure Components
- **VPC**: Multi-AZ VPC named `project-bedrock-vpc` with public and private subnets.
- **EKS Cluster**: Amazon EKS cluster named `project-bedrock-cluster` (v1.30) with managed node groups.
- **Data Layer**: Amazon RDS (MySQL and PostgreSQL) and Amazon DynamoDB tables for offloading the in-cluster databases.
- **Serverless**: An S3 bucket (`bedrock-assets-alt-soe-025-4492`) that triggers a Lambda function (`bedrock-asset-processor`) upon image upload.
- **IAM Security**: `bedrock-dev-view` IAM user with ReadOnlyAccess and cluster View access.

## Deployment Guide

### Prerequisites
- AWS Credentials configured with sufficient permissions.
- Terraform >= 1.5.0
- Helm and kubectl

### CI/CD Pipeline
This repository uses GitHub Actions for fully automated deployments.
1. **Pull Request**: Creating a PR to the `main` branch will automatically trigger a `terraform plan`.
2. **Merge**: Merging the PR to the `main` branch triggers `terraform apply`, which provisions the infrastructure and deploys the Helm chart. The pipeline also commits the `grading.json` output file back to the repository.

### Manual Helm Deployment (Bonus Objective)
The application is automatically deployed via the Terraform Helm provider. If you wish to manually upgrade or install the Helm chart using the upstream repository and the provisioned infrastructure outputs:

1. Obtain the DB endpoints and passwords from AWS Secrets Manager and Terraform state.
2. Run the following command:
```bash
helm upgrade --install retail-store oci://public.ecr.aws/aws-containers/retail-store-sample-app \
  --namespace retail-app --create-namespace \
  --set ui.ingress.enabled=true \
  --set ui.ingress.annotations."kubernetes\.io/ingress\.class"=alb \
  --set catalog.mysql.enabled=false \
  --set catalog.env.DB_HOST=<MYSQL_ENDPOINT> \
  --set catalog.env.DB_USER=admin \
  --set catalog.env.DB_PASSWORD=<MYSQL_PASSWORD> \
  --set orders.postgres.enabled=false \
  --set orders.env.DB_HOST=<POSTGRES_ENDPOINT> \
  --set orders.env.DB_USER=admin \
  --set orders.env.DB_PASSWORD=<POSTGRES_PASSWORD> \
  --set carts.dynamodb.enabled=true \
  --set carts.env.DYNAMODB_TABLE_NAME=bedrock-carts
```

### Accessing the Application
Once the ALB Ingress Controller provisions the load balancer, you can obtain the URL to access the retail store by running:
```bash
kubectl get ingress -n retail-app
```
Navigate to the `ADDRESS` provided by the output in your browser.
