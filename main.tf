resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "agnivega-vpc"
    Environment = "dev"
    Project     = "Sprint-1"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "agnivega-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "agnivega-private-subnet"
  }
}
resource "aws_security_group" "web" {
  name        = "agnivega-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "agnivega-web-sg"
    Environment = "dev"
    Project     = "Sprint-1"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "agnivega-igw"
    Environment = "dev"
    Project     = "Sprint-1"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "agnivega-public-route-table"
    Environment = "dev"
    Project     = "Sprint-1"
  }
}



resource "aws_key_pair" "bastion" {
  key_name   = "agnivega-bastion-key"
  public_key = file("~/.ssh/id_ed25519.pub")

  tags = {
    Name        = "agnivega-bastion-key"
    Environment = "dev"
    Project     = "Sprint-1"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0d15e9052c94acb75"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.bastion.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "agnivega-bastion"
    Environment = "dev"
    Project     = "Sprint-1"
    Role        = "bastion-jenkins"
  }
}










resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "bastion" {
  name        = "agnivega-bastion-sg"
  description = "Security group for Bastion Host and Jenkins"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from approved IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.164.240.221/32"]
  }

  ingress {
    description = "Jenkins Web UI from approved IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["103.164.240.221/32"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "agnivega-bastion-sg"
    Environment = "dev"
    Project     = "Sprint-1"
  }
}
