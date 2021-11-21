resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "nextcloud_vpc"
  }
}

# Defining Subnets
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.public_subnet

  tags = {
    Name = "nextcloud_subnet_public"
  }
}
# NAT Network / Gateway
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.private_subnet

  tags = {
    Name = "nextcloud_subnet_private"
  }
}
# Server Local Link
resource "aws_subnet" "local" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.local_subnet

  tags = {
    Name = "nextcloud_subnet_local"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "nextcloud_gw"
  }
}
resource "aws_eip" "nextcloud" {
  vpc               = true
  network_interface = aws_network_interface.server_public.id

  depends_on = [
    aws_internet_gateway.gw
  ]

  tags = {
    Name = "nextcloud_eip_app"
  }
}
output "app_eip" {
  value = aws_eip.nextcloud.public_ip
}

resource "aws_eip" "NAT" {
  vpc = true

  depends_on = [
    aws_internet_gateway.gw
  ]

  tags = {
    Name = "nextcloud_eip_ngw"
  }
}
resource "aws_nat_gateway" "NAT" {
  connectivity_type = "public"
  allocation_id     = aws_eip.NAT.id
  subnet_id         = aws_subnet.public.id

  depends_on = [
    aws_internet_gateway.gw
  ]

  tags = {
    Name = "nextcloud_NATgw"
  }
}

output "ngw_eip" {
  value = aws_eip.NAT.public_ip
}

