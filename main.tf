# Provider Configuration
provider "aws" {
  region = "af-south-1"
}

variable "ec2_private_key" {
  description = "The name of the EC2 key pair to use"
  type        = string
}

# Security Group Check (Data Source)
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["ci-cd-webcounter-access"]
  }
}

# Security Group Creation (Only if not found)
resource "aws_security_group" "webcounter_sg" {
  count       = length(data.aws_security_group.existing_sg.ids) == 0 ? 1 : 0
  name        = "ci-cd-webcounter-access"
  description = "Allow HTTP, SSH, and PostgreSQL access"
  vpc_id      = "vpc-00e5757e0834b17c4"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Check for existing EC2 Instance (Data Source)
data "aws_instance" "existing_instance" {
  filter {
    name   = "tag:Name"
    values = ["ci-cd-webcounter"]
  }
}

# EC2 Instance Creation (Only if not found)
resource "aws_instance" "ci-cd-webcounter" {
  count         = length(data.aws_instance.existing_instance.ids) == 0 ? 1 : 0
  ami           = "ami-00a3e6c53c910eba6"
  instance_type = "t3.micro"
  key_name      = var.ec2_private_key
  subnet_id     = "subnet-034e3d26503920841"

  vpc_security_group_ids = length(data.aws_security_group.existing_sg.ids) > 0 ? 
    [data.aws_security_group.existing_sg.id] : 
    [aws_security_group.webcounter_sg[0].id]

  tags = {
    Name = "ci-cd-webcounter"
  }
}

# Output EC2 Public IP
output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = length(data.aws_instance.existing_instance.ids) > 0 ? 
                data.aws_instance.existing_instance.public_ip : 
                aws_instance.ci-cd-webcounter[0].public_ip
}
