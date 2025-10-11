# 🧺 GroceryMate on AWS — Cloud-Native E‑Commerce

[![Python](https://img.shields.io/badge/Language-Python%20%7C%20JavaScript-blue  )](https://www.python.org/  )
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC  )](https://www.terraform.io/  )
[![Database](https://img.shields.io/badge/DB-PostgreSQL-336791  )](https://www.postgresql.org/  )
[![Cloud](https://img.shields.io/badge/Cloud-AWS-orange  )](https://aws.amazon.com/  )
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED  )](https://www.docker.com/  )
[![License](https://img.shields.io/badge/License-MIT-green  )](#-license)

This repository provides the Terraform Infrastructure as Code (IaC) to deploy the GroceryMate application on AWS. The setup includes a VPC, EC2 instance for the application server, RDS PostgreSQL database, and an S3 bucket for avatar storage. The application is designed to run within a Docker container on the EC2 instance, all configured for security and scalability.

## 📸 Architecture Diagram

![Architecture Diagram](https://github.com/user-attachments/assets/d408ba1f-d0b2-43a0-84f0-33fff93dcb3f)

## 🚀 Deployment Guide

### Prerequisites

*   **AWS Account**: An active AWS account with permissions to create VPCs, EC2, RDS, S3, and IAM resources.
*   **AWS CLI**: Installed and configured with `aws configure`.
*   **Terraform**: Version 1.0 or later installed locally.
*   **SSH Key Pair**: An existing key pair in your chosen AWS region for accessing the EC2 instance. The default name expected is `aws-ssh`.

### Infrastructure Components

*   **Virtual Private Cloud (VPC)**: A dedicated network (`10.0.0.0/16` by default) with public and private subnets.
*   **Application Server (EC2)**: An `t2.micro` Amazon Linux 2023 instance in the public subnet, running the GroceryMate Flask application.
*   **Database (RDS)**: A `db.t3.micro` PostgreSQL instance in the private subnets, accessible only by the application server.
*   **Avatar Storage (S3)**: A secure S3 bucket (`grocerymate-app-avatars` by default) for storing user avatars.
*   **Networking & Security**: Security groups, route tables, and IAM roles configured for secure communication and minimal access.

### Deployment Steps

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/mat85sy/AWS_grocery.git
    cd AWS_grocery/infrastructure
    ```

2.  **Initialize Terraform**:
    ```bash
    terraform init
    ```

3.  **(Optional) Customize Variables**:
    Create a `terraform.tfvars` file in the `infrastructure` directory to override default settings from `variables.txt`. The following variables are recommended to be customized:

    *   `key_name`: **(Required)** The name of your existing AWS SSH key pair (e.g., `my-key-pair`). The default `aws-ssh` must exist in your AWS account.
    *   `db_password`: **(Required)** A secure password for the database. The default `YourSecretPassword123` should be changed.
    *   `project_name`: (Optional) Name used for resource tagging (default: `grocerymate`).
    *   `aws_region`: (Optional) The AWS region (default: `eu-central-1`).
    *   `s3_bucket_name`: (Optional) Name for the S3 bucket (default: `grocerymate-app-avatars`).

    Example `terraform.tfvars`:
    ```hcl
    project_name = "my-grocery-project"
    aws_region   = "us-east-1"
    key_name     = "my-ssh-key"
    s3_bucket_name = "my-custom-avatar-bucket"
    db_password  = "MySuperSecurePassword123!"
    ```

4.  **Plan the Deployment**:
    Review the changes Terraform will make.
    ```bash
    terraform plan
    ```

5.  **Deploy**:
    Apply the configuration. Confirm when prompted.
    ```bash
    terraform apply
    ```

6.  **Start the Application Using Docker**:
    The application runs within a Docker container on the EC2 instance. The application files are already present on the EC2 instance in the `/home/ec2-user/AWS_grocery/backend` directory, which contains the Dockerfile.
    
    a. SSH into the EC2 instance using the public IP from Terraform output:
    ```bash
    ssh -i /path/to/your/private-key.pem ec2-user@<EC2_PUBLIC_IP>
    ```
     
    b. Navigate to the backend directory:
    ```bash
    cd /home/ec2-user/AWS_grocery/backend
    ```
    
    c. Verify Docker Installation and Start Service:
    ```bash
    docker --version
    sudo systemctl start docker
    sudo systemctl enable docker
    ```
    If Docker is not installed, install it using the following commands:
    ```bash
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
    # Log out and log back in for group changes to take effect, or run:
    newgrp docker
    docker --version
    ```
    
    d. Populate Database:
       Use the `psql` command-line tool to load the initial data from the provided SQL dump file into your RDS instance. Replace `<rds-endpoint>` with the actual endpoint of your RDS instance (found in the AWS console or Terraform outputs).
       ```bash
       psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -f backend/app/sqlite_dump_clean.sql
       ```
       *   When prompted for a password, enter the value you set for `db_password` in your `terraform.tfvars` file (the default is `YourSecretPassword123` if you didn't change it).
    
    e. Verify Insertion:
       Run these commands to confirm the data was loaded correctly. Replace `<rds-endpoint>` with your RDS endpoint.
       ```bash
       psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -c "SELECT COUNT(*) FROM users;"
       psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -c "SELECT COUNT(*) FROM products;"
       ```
    
    f. Configure Environment Variables:
       Create the `.env` file and populate it with necessary variables. The `JWT_SECRET_KEY` will be generated automatically.
       ```bash
       touch .env
       echo "JWT_SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')" >> .env
       echo "S3_BUCKET_NAME=<your_s3_bucket_name>" >> .env
       echo "S3_REGION=<your_aws_region>" >> .env
       echo "USE_S3_STORAGE=true" >> .env
       echo "POSTGRES_USER=grocery_user" >> .env
       echo "POSTGRES_PASSWORD=<your_db_password>" >> .env
       echo "POSTGRES_DB=grocerymate_db" >> .env
       echo "POSTGRES_HOST=<rds-endpoint>" >> .env
       echo "POSTGRES_URI=postgresql://grocery_user:<your_db_password>@<rds-endpoint>:5432/grocerymate_db" >> .env
       ```
       Remember to replace `<rds-endpoint>` with your actual RDS endpoint, `<your_s3_bucket_name>` with your S3 bucket name (default: `grocerymate-app-avatars`), `<your_aws_region>` with your AWS region (default: `eu-central-1`), and `<your_db_password>` with the password you set for the database (either the default `YourSecretPassword123` or your custom value set in `terraform.tfvars`).
    
    g. Build and Run the Docker Container:
       Build the Docker image and run the application container using the environment variables from `.env`.
       ```bash
       docker build -t grocerymate .
       docker run -d --env-file .env -p 5000:5000 grocerymate
       ```

    h. Access the Application:
    After the application starts successfully, open your browser and navigate to `http://<EC2_PUBLIC_IP>:5000`.

7. **Using the Application**:

*   The application will be ready to use according to its features (e.g., managing grocery lists).
*   Avatars are uploaded to the configured S3 bucket.

8. **Cleanup**:

   To avoid ongoing charges, destroy the infrastructure when finished.

    ```bash
    terraform destroy
    ```
## 🔍 Enhanced Observability: VPC Flow Logs Integration

To improve the operational visibility and security posture of the infrastructure, **AWS VPC Flow Logs** were integrated into the Terraform configuration.

### Integration Details

*   **Service Added:** AWS VPC Flow Logs.
*   **Purpose:** To capture detailed information about IP traffic going to and from network interfaces within the `grocerymate` VPC. This provides insights into network usage, helps troubleshoot connectivity issues, and enhances security analysis.
*   **Method:** The integration was achieved purely through modifications to the Terraform configuration (`main.tf`).
    *   A new CloudWatch Log Group (`/aws/vpc/flowlogs/grocerymate-vpc`) was created to store the flow log data.
    *   A dedicated IAM role (`grocerymate-vpc-flow-log-role`) with the necessary trust policy and `CloudWatchLogsFullAccess` permissions was created for the VPC Flow Logs service.
    *   The `aws_flow_log` resource was added, targeting the main VPC (`grocerymate-vpc`) and configured to log `ALL` traffic to the newly created CloudWatch Log Group using the dedicated IAM role.

### Impact

*   **Enhanced Monitoring:** Network traffic within the VPC is now logged and accessible via AWS CloudWatch Logs.
*   **Security:** Provides an additional layer of network-level monitoring for potential security analysis.
*   **Operational Insight:** Facilitates easier troubleshooting of network-related issues.
*   **Cost:** A minimal cost is associated with storing the flow log data in CloudWatch.

## **📝 Notes**:

*   The default security group for the EC2 instance allows SSH (`22`), HTTP (`80`), and application traffic (`5000`) from `0.0.0.0/0`. For production, restrict SSH access to your IP.
*   The application code is automatically cloned from `https://github.com/mat85sy/AWS_grocery.git` during EC2 startup.
*   The RDS instance is configured with `skip_final_snapshot = true`. Consider enabling snapshots for production environments.

## **🛡️ License**:

   This project is licensed under the MIT License.

   This software and its associated documentation were developed as part of the Masterschool Cloud Engineering program in 2025. We extend our thanks to Alejandro Roman Ibanez, Thomas Ressel, Jonas Adamietz and Vlasis Ioannidis for their guidance and support throughout the development process.
