# Resource-1: create VPC and call it CSD-VPC
resource "aws_vpc" "CSD-VPC" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "CSD-VPC"
  }
}

# Resource-2: create Subnet pub
resource "aws_subnet" "CSD-VPC-Pub-sbn" {
  vpc_id     = aws_vpc.CSD-VPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
    tags = {
    Name = "CSD-VPC-Pub-sbn"
  }
}

# Resource-3: create Subnet prv
resource "aws_subnet" "CSD-VPC-Prv-sbn" {
  vpc_id     = aws_vpc.CSD-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
    tags = {
    Name = "CSD-VPC-Prv-sbn"
  }
}

# Resource-4: create internet gatewaay
resource "aws_internet_gateway" "CSD-VPC-igw" {
  vpc_id = aws_vpc.CSD-VPC.id
  
  tags = {
    Name = "CSD-VPC-igw"
  }
}

# Resource-5: create public route table
resource "aws_route_table" "CSD-VPC-Pub-RT" {
  vpc_id = aws_vpc.CSD-VPC.id
}

# Resource-6: create prv route table
resource "aws_route_table" "CSD-VPC-Prv-RT" {
  vpc_id = aws_vpc.CSD-VPC.id
}

# Resource-7: create route
resource "aws_route" "CSD-VPC-Pub-Route" {
  route_table_id            = aws_route_table.CSD-VPC-Pub-RT.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.CSD-VPC-igw.id
  depends_on                = [aws_route_table.CSD-VPC-Pub-RT]
  count                     = "1"
}

# Resource-8: Associate Public Route Table with Public subnet
resource "aws_route_table_association" "CSD-VPC-Pub-RT-Asso" {
  subnet_id      = aws_subnet.CSD-VPC-Pub-sbn.id
  route_table_id = aws_route_table.CSD-VPC-Pub-RT.id
}

# Resource-9: Associate Prv Route Table with Prv subnet
resource "aws_route_table_association" "CSD-VPC-Prv-RT-Asso" {
  subnet_id      = aws_subnet.CSD-VPC-Prv-sbn.id
  route_table_id = aws_route_table.CSD-VPC-Prv-RT.id
}

#  To replace all same phrase at once with a new phrase ~~~>>> Ctrl + Shift + L  and paste the new phrase.