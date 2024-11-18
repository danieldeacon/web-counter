provider "aws" {
  region = "af-south-1"
}

resource "aws_security_group" "webcounter_sg" {
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

resource "aws_instance" "ci-cd-webcounter" {
  ami           = "ami-0f256846cac23da94"
  instance_type = "t3.micro"
  key_name      = "myDefaultKeyPair"
  subnet_id     = "subnet-034e3d26503920841"

  vpc_security_group_ids = [aws_security_group.webcounter_sg.id]

  tags = {
    Name = "ci-cd-webcounter"
  }
}

output "ec2_public_dns" {
  description = "The public DNS of the EC2 instance"
  value       = aws_instance.ci-cd-webcounter.public_dns
}