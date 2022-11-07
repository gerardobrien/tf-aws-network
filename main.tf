# Build AWS VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.50.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name  = "Lab VPC"
    Owner = "Gerard O'Brien"
  }
}


# Create Multiple Subnets

# Subnet for management access
resource "aws_subnet" "mgmt-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.50.0.0/24"

  tags = {
    Name  = "MGMT Subnet"
    VPC  = "Lab VPC"
    Owner = "Gerard O'Brien"
  }
}

# Subnet for application servers
resource "aws_subnet" "app-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.50.1.0/24"

  tags = {
    Name  = "Application Subnet"
    VPC  = "Lab VPC"
    Owner = "Gerard O'Brien"
  }
}

# Subnet for database servers
resource "aws_subnet" "db-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.50.2.0/24"

  tags = {
    Name  = "Database Subnet"
    VPC  =  "Lab VPC"
    Owner = "Gerard O'Brien"
  }
}


# Create an Internet Gateway
resource "aws_internet_gateway" "lab-inet-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "LAB VPC Inet GW"
    VPC  =  "Lab VPC"
    Owner = "Gerard O'Brien"
  }
}

# Create a Route Table
resource "aws_route_table" "lab-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab-inet-gw.id
  }

  tags = {
    Name  = "LAB Subnet Route Table"
    VPC  =  "Lab VPC"
    Owner = "Gerard O'Brien"
  }
}


# Assign Route Table to subnets
resource "aws_route_table_association" "mgmt-subnet-rt" {
  subnet_id = aws_subnet.mgmt-subnet.id
  route_table_id = aws_route_table.lab-route-table.id
}

resource "aws_route_table_association" "app-subnet-rt" {
  subnet_id = aws_subnet.app-subnet.id
  route_table_id = aws_route_table.lab-route-table.id
}

resource "aws_route_table_association" "db-subnet-rt" {
  subnet_id = aws_subnet.db-subnet.id
  route_table_id = aws_route_table.lab-route-table.id
}


# Create a Public IP
resource "aws_eip" "lab-nat-gw-ip" {

tags = {
    Name  = "LAB NAT GW PIP"
    VPC  =  "Lab VPC"
    Owner = "Gerard O'Brien"
  }
}

# Create a NAT Gateway
resource "aws_nat_gateway" "lab-nat-gw" {
  connectivity_type = "public"
  allocation_id = aws_eip.lab-nat-gw-ip.id
  subnet_id     = aws_subnet.app-subnet.id

  tags = {
    Name  = "LAB VPC NAT GW"
    VPC  =  "Lab VPC"
    Owner = "Gerard O'Brien"
  }

  depends_on = [aws_internet_gateway.lab-inet-gw]
}