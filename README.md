# InnovateMart: Project Bedrock

This repository contains the Infrastructure as Code (IaC) and Application configurations to deploy the InnovateMart Retail Store on AWS EKS.

## Architecture

* **VPC**: `project-bedrock-vpc` in `us-east-1` with public/private subnets across 2 AZs.
* **EKS**: `project-bedrock-cluster` (v1.31) running managed node groups in private subnets.
* **Data Layer**:
  * **Amazon RDS (MySQL)** for Catalog microservice.
  * **Amazon RDS (PostgreSQL)** for Orders microservice.
  * **Amazon DynamoDB** for Cart microservice.
* **Serverless**: AWS Lambda function triggered by S3 uploads to the assets bucket.
* **Observability**: CloudWatch Logs for EKS Control Plane and Container Logs.

## Deployment Guide

This project is fully automated using GitHub Actions. To deploy:

1. Ensure the following secrets are configured in your GitHub repository:
   * `AWS_ACCESS_KEY_ID`
   * `AWS_SECRET_ACCESS_KEY`
2. Push or merge changes to the `main` branch.
3. The GitHub Actions workflow will automatically:
   * Initialize Terraform and create the required remote backend S3 bucket.
   * Provision the AWS infrastructure (VPC, EKS, RDS, DynamoDB, S3, Lambda).
   * Install the AWS Load Balancer Controller and CloudWatch Observability Add-on.
   * Deploy the Retail Store application via Helm.
   * Generate `grading.json` and push it to the repository.

### Accessing the Retail Store

Once the pipeline completes successfully, retrieve the Application Load Balancer (ALB) URL:

```bash
# Ensure your local machine is authenticated to the EKS cluster
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1

# Get the ALB Ingress URL
kubectl get ingress ui -n retail-app
```

Navigate to the `ADDRESS` shown in the output in your web browser.

### Verifying the IAM Developer User

Terraform automatically provisions the `bedrock-dev-view` IAM user. The access credentials will be printed in the Terraform output logs and `grading.json`.

1. Configure your local AWS CLI with these credentials.
2. Verify you can view pods:
   ```bash
   kubectl get pods -n retail-app
   ```
3. Verify you **cannot** delete pods:
   ```bash
   kubectl delete pod <pod-name> -n retail-app
   # Should return: Error from server (Forbidden)
   ```

### Verifying the S3 / Lambda Event-Driven Flow

Upload an image to the S3 bucket to trigger the image processor Lambda:

```bash
# Upload a test file
aws s3 cp test-image.jpg s3://bedrock-assets-[STUDENT-ID]/

# Verify the Lambda was invoked by checking its CloudWatch Logs
aws logs filter-log-events --log-group-name /aws/lambda/bedrock-asset-processor
```

## Bonus Objectives Implemented

* **5.1 Helm-Based Deployment**: The `retail-store-sample-app` is packaged as a Helm chart in `./helm-chart` and deployed automatically via Terraform (`helm_release`).
