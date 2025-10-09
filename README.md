# 🧺 GroceryMate on AWS — Cloud-Native E‑Commerce

[![Python](https://img.shields.io/badge/Language-Python%20%7C%20JavaScript-blue  )](https://www.python.org/  )
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC  )](https://www.terraform.io/  )
[![Database](https://img.shields.io/badge/DB-PostgreSQL-336791  )](https://www.postgresql.org/  )
[![Cloud](https://img.shields.io/badge/Cloud-AWS-orange  )](https://aws.amazon.com/  )
[![License](https://img.shields.io/badge/License-MIT-green  )](#-license)

This repository provides the Terraform Infrastructure as Code (IaC) to deploy the GroceryMate application on AWS. The setup includes a VPC, EC2 instance for the application server, RDS PostgreSQL database, and an S3 bucket for avatar storage, all configured for security and scalability.

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
    Create a `terraform.tfvars` file in the `infrastructure` directory to override default settings from `variables.tf`. The following variables are recommended to be customized:

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

6.  **Start the Application Manually**:
    The application does not start automatically after Terraform deployment. You need to SSH into the EC2 instance and start it manually.
    
    a. SSH into the EC2 instance using the public IP from Terraform output:
    ```bash
    ssh -i /path/to/your/private-key.pem ec2-user@<EC2_PUBLIC_IP>
    ```
    
    b. Navigate to the backend directory:
    ```bash
    cd /home/ec2-user/AWS_grocery/backend
    ```
    c. Populate Database:
       Use the `psql` command-line tool to load the initial data from the provided SQL dump file into your RDS instance. Replace `<rds-endpoint>` with the actual endpoint of your RDS instance (found in the AWS console or Terraform outputs).
       ```bash
       psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -f backend/app/sqlite_dump_clean.sql
       ```
    
    d. Verify Insertion:
       Run these commands to confirm the data was loaded correctly. Replace `<rds-endpoint>` with your RDS endpoint.
       ```bash
       psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -c "SELECT COUNT(*) FROM users;"
       psql -h <rds-endpoint> -U grocery_user -d grocerymate_db -c "SELECT COUNT(*) FROM products;"
       ```
    e. Install Dependencies (Optional - Dependencies are installed automatically during instance creation, but run this to ensure they are up-to-date):
    ```bash
    pip3 install --upgrade pip
    pip3 install -r requirements.txt
    ```
    
    f. Start the Flask backend:
    ```bash
    python3 run.py
    ```

### Using the Application
*   open your browser and navigate to `http://<EC2_PUBLIC_IP>:5000`.
*   The application will be ready to use according to its features (e.g.Product Catalog,Shopping Cart).
*   Avatars are uploaded to the configured S3 bucket.

### Cleanup

To avoid ongoing charges, destroy the infrastructure when finished.

```bash
terraform destroy
```
Confirm when prompted.


## Running using Docker (Alternative Method)

If you prefer to run the backend application using Docker instead of the direct Python command, follow these steps. The application files are already present on the EC2 instance in the `/home/ec2-user/AWS_grocery/backend` directory, which contains the Dockerfile.

1.  **Verify Docker Installation and Navigate**
    Check if Docker is installed and navigate to the application directory.
    ```bash
    docker --version
    cd /home/ec2-user/AWS_grocery/backend
    ```
    If Docker is not installed, install it using the following commands:
    ```bash
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -aG docker ec2-user
    # Log out and log back in for group changes to take effect, or run:
    newgrp docker
    docker --version
    ```

2.  **Configure Environment Variables**
    Create the `.env` file and populate it with necessary variables. The `JWT_SECRET_KEY` will be generated automatically.
    ```bash
    touch .env
    echo "JWT_SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')" >> .env
    echo "POSTGRES_USER=grocery_user" >> .env
    echo "POSTGRES_PASSWORD=grocery_test" >> .env
    echo "POSTGRES_DB=grocerymate_db" >> .env
    echo "POSTGRES_HOST=<rds-endpoint>" >> .env
    echo "POSTGRES_URI=postgresql://grocery_user:grocery_test@<rds-endpoint>:5432/grocerymate_db" >> .env
    ```
    Remember to replace `<rds-endpoint>` with your actual RDS endpoint from the Terraform output or AWS console.

3.  **Build and Run the Docker Container**
    Build the Docker image and run the application container using the environment variables from `.env`.
    ```bash
    docker build -t grocerymate .
    docker run -d --env-file .env -p 5000:5000 grocerymate
    ```

## 📝 Notes

*   The default security group for the EC2 instance allows SSH (`22`), HTTP (`80`), and application traffic (`5000`) from `0.0.0.0/0`. For production, restrict SSH access to your IP.
*   The application code is automatically cloned from `https://github.com/mat85sy/AWS_grocery.git` during EC2 startup.
*   The RDS instance is configured with `skip_final_snapshot = true`. Consider enabling snapshots for production environments.

## 🛡️ License

This project is licensed under the MIT License.

This software and its associated documentation were developed as part of the Masterschool Cloud Engineering program in 2025. We extend our thanks to Alejandro Roman Ibanez, Thomas Ressel, Jonas Adamietz and Vlasis Ioannidis for their guidance and support throughout the development process.
