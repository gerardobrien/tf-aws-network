# Build AWS VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.50.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name  = "Lab Subnet"
    Owner = "Gerard O'Brien"
  }
}