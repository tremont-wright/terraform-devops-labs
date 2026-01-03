provider "aws" {
  region = "us-east-2"
}

# -------------------------
# S3
# -------------------------
resource "aws_s3_bucket" "bucket" {
  bucket = "imperium-maris-terraform-test-1801"
}

# -------------------------
# VPC + Public Subnet
# -------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "lab-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "lab-public-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "lab-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "lab-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Security Group
# -------------------------
resource "aws_security_group" "web_sg" {
  name        = "lab-web-sg"
  description = "Allow SSH inbound, all outbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab-web-sg"
  }
}

# -------------------------
# EC2 Instance
# -------------------------
resource "aws_instance" "web" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Amazon Linux 2 in us-east-2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "lab-ec2"
  }
}


