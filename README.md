# Project Bedrock — EKS Capstone Submission

**Author:** Ndubuisi Ebenezer Uchenna  
**AltSchool ID:** ALT/SOE/025/5599

## Overview
Project Bedrock is a comprehensive deployment of the AWS Retail Store Sample App using Infrastructure as Code (IaC) and Kubernetes. This project demonstrates advanced cloud engineering practices by provisioning a secure, highly available architecture on AWS, establishing a fully automated CI/CD pipeline, and successfully deploying a complex microservices architecture.

## Architecture

The infrastructure is provisioned using Terraform and is deployed entirely in the `us-east-1` region. It consists of the following core components:

* **VPC & Networking:** A custom Virtual Private Cloud with public and private subnets distributed across multiple Availability Zones, utilizing NAT Gateways for secure outbound internet access.
* **Amazon EKS:** A managed Kubernetes cluster (`retail-app`) running on AWS.
* **Database Layer:** 
  * Fully managed **Amazon RDS** instances (MySQL for the Catalog service, PostgreSQL for the Orders service).
  * **Amazon DynamoDB** (used for the Carts service).
* **Event-Driven Storage:** An S3 Bucket configured to trigger an AWS Lambda function upon object creation, streaming logs to CloudWatch Logs.
* **Load Balancing:** A Classic AWS Load Balancer exposing the Kubernetes UI service to the public internet securely over HTTP.

## CI/CD Pipeline

The deployment process is fully automated using **GitHub Actions**. 
The pipeline (`.github/workflows/terraform-ci-cd.yml`) is triggered automatically on every push to the `main` branch. It executes the following stages:
1. **Terraform Execution:** Initializes the working directory, validates the configuration, generates an execution plan, and applies the IaC to update the AWS infrastructure.
2. **Kubernetes Deployment:** Authenticates with the newly provisioned EKS cluster and automatically applies the Kubernetes manifests and Helm charts to deploy the microservices.

## Challenges and Optimizations

Deploying a complex microservices application onto a constrained AWS environment required several advanced optimizations:

1. **Memory Exhaustion on Free Tier Nodes:** 
   The default Helm charts requested up to 2.5 GiB of RAM, preventing the pods from scheduling. This was solved by aggressively overriding the memory requests in the Helm deployment configuration down to `64Mi`, allowing the pods to fit within the memory limits.
2. **AWS ENI Pod Limits:**
   By default, AWS imposes strict ENI IP limits on smaller instances, capping `t3.micro` nodes to just 4 pods. This blocked the microservices from starting. The node group was scaled to use `t3.small` instances, natively doubling the RAM and increasing the `max-pods` limit to 11 per node, successfully eliminating the bottleneck.
3. **Database Indexing Mismatches:**
   The `carts` service repeatedly entered a `CrashLoopBackOff` state due to a missing Global Secondary Index in DynamoDB. The Terraform configuration was updated to accurately name the index `idx_global_customerId`, instantly stabilizing the microservice.

## Accessing the Application

The frontend UI is publicly accessible via the AWS Load Balancer DNS. 
*(Note: Ensure you access the URL via `http://` and not `https://`, as the Load Balancer does not utilize an SSL certificate).*
