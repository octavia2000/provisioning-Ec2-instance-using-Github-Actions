provider "aws" {
  region = "us-east-2"
}

# 1. Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# 2. Create Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

# 3. Create Security Group (SSH only)
resource "aws_security_group" "main" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

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

# 4. Create EC2 Instance (Ubuntu)
resource "aws_instance" "app_server" {
  ami                         = "ami-053b0d53c279acc90"  # Ubuntu 22.04 us-east-2
  instance_type               = "t3.micro"
  key_name                    = "app-ssh-key"            # Ensure this key exists in us-east-2
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.main.id]

  tags = {
    Name = "UbuntuAppServer"
  }
}
