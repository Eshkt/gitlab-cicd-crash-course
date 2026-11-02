# Gitlab CI/CD Crash Course - DevOps Operations

This project is a comprehensive demonstration of DevOps operations, focusing on the end-to-end lifecycle of a Python Flask web application. It showcases Infrastructure as Code (IaC), Continuous Integration (CI), and Continuous Deployment (CD) using GitLab CI/CD and AWS.

## 🚀 Project Overview

The project implements a full DevOps pipeline to deploy a monitoring web application to AWS. The core focus is on automating the infrastructure provisioning and the application deployment process.

### Key DevOps Components:

- **Infrastructure as Code (IaC):** Uses **Terraform** to provision a complete AWS network stack.
- **CI/CD Pipeline:** A **GitLab CI/CD** pipeline that automates testing, containerization, and deployment.
- **Containerization:** **Docker** is used to package the application for consistent deployment.
- **Web Serving:** **Nginx** is configured as a reverse proxy with **SSL/TLS** encryption for secure access.
- **Cloud Provider:** Hosted on **AWS (Amazon Web Services)**.

## 🛠️ Technical Architecture

### ☁️ AWS Infrastructure (via Terraform)
The `main.tf` file defines the following resources:
- **VPC:** Custom Virtual Private Cloud for isolation.
- **Networking:** Internet Gateway, Public Subnets, and Route Tables.
- **Security:** Security Groups configured to allow SSH (22), HTTP (80), and HTTPS (443).
- **Compute:** EC2 instance acting as the application host.
- **Connectivity:** Elastic IP (EIP) and Network Interfaces for stable access.

### 🔄 CI/CD Pipeline (via `.gitlab-ci.yml`)
The pipeline consists of the following stages:
1. **Test:** Runs unit tests using `make test`.
2. **Dockerize:** Builds the Docker image and pushes it to Docker Hub.
3. **Deploy Test:** Validates environment variables and SSH connectivity.
4. **Deploy:** 
   - Connects to the EC2 instance via SSH.
   - Installs and configures Nginx.
   - Generates a self-signed SSL certificate.
   - Pulls and runs the latest Docker container.
5. **Inspect EC2:** Verifies the deployment by checking Nginx configurations and port status on the host.

## 💻 Local Development & Setup

### Pre-requisites
- Python 3.9+
- Docker
- Terraform (for infra management)
- Make (for shortcuts)

### Running Locally
Use the provided `makefile` for common tasks:
```bash
make test    # Run unit tests
make image   # Build the Docker image
```

## 📁 Project Structure
- `main.tf`: Terraform configuration for AWS infrastructure.
- `.gitlab-ci.yml`: GitLab CI/CD pipeline definition.
- `Dockerfile`: Docker configuration for the Flask app.
- `src/`: Application source code (Python/Flask).
- `deploy/`: Kubernetes and Bicep templates for alternative deployments.
- `makefile`: Automation shortcuts for local development.

---
*This project serves as a practical guide for implementing modern DevOps practices in a cloud environment.*
