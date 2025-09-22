resource "aws_db_instance" "database" {
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "17.4"
  instance_class          = "db.t3.micro"
  db_subnet_group_name    = "aws-grocery"
  skip_final_snapshot     = true
  publicly_accessible     = false
  storage_type            = "gp2"
  username                = "postgres"
  port                    = 5432
  backup_retention_period = 0
  auto_minor_version_upgrade = true
  parameter_group_name    = "default.postgres17"
  deletion_protection     = false
  vpc_security_group_ids  = [
    "sg-0373187a05ea26c1a",
    "sg-06cf476f1eb014b79",
  ]

  tags = {
    Name = "grocery-db"
  }
}
resource "aws_instance" "web_server" {
  ami                         = "ami-0600d3b28b3d8d3ab"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-05beb302069aa6671"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "sg-02bf6ef5223a096db",
    "sg-05a5e556b25ec188c",
    "sg-0cf9dc9de73e81f41",
  ]

  key_name = "aws-ssh"

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
    delete_on_termination = true
  }

  tags = {
    Name = "aws-grocery"
  }
}
