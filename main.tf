# Provider Configuration
provider "aws" {
  region     = "af-south-1"
  access_key =  var.aws_access_key
  secret_key = var.aws_secret_key
}

# Security Group
resource "aws_security_group" "webcounter_sg" {
  name        = "ci-cd-webcounter-access"
  description = "Allow HTTP, SSH, and PostgreSQL access"
  vpc_id      = "vpc-00e5757e0834b17c4"

  # Inbound rule for HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule for PostgreSQL (port 5432)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule (Allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "ci-cd-webcounter" {
  ami           = "ami-0f256846cac23da94"
  instance_type = "t3.micro"
  key_name      = var.ec2_private_key
  subnet_id     = "subnet-034e3d26503920841"

  # Attach security group
  vpc_security_group_ids = [aws_security_group.webcounter_sg.id]

  tags = {
    Name = "ci-cd-webcounter"
  }
}
