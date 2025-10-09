variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.11.0/24"
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
  default     = "eu-central-1a"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "eu-central-1b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-08697da0e8d9f59ec"  # Amazon Linux 2023 in eu-central-1
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.4"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "grocerymate_db"
}

variable "db_username" {
  description = "Master username for database"
  type        = string
  default     = "grocery_user"
}

variable "db_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
  default     = "YourSecretPassword123"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for avatars"
  type        = string
  default     = "grocerymate-app-avatars"
}

variable "key_name" {
  description = "Name of existing AWS key pair"
  type        = string
  default     = "aws-ssh"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "grocerymate"
}

