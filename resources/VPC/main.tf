# CREATE VPC
resource "aws_vpc" "VPC" {
  cidr_block           = var.CIDR_BLOCK_VPC
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name"     = "${var.STACK_NAME}-VPC"
    "StackEnv" = var.STACK_NAME
  }
}

# CREATE ELASTIC IP NAT GW ZONE A
resource "aws_eip" "EipNatGWZoneA" {
  vpc = true
  tags = {
    "Name"     = "${var.STACK_NAME}-EIP-NAT-A"
    "StackEnv" = var.STACK_NAME
  }
}

# CREATE NAT GATEWAY AND ASSOCITATE TO SUBNET PUBLIC IN ZONE A
resource "aws_nat_gateway" "NatGWZoneA" {
  depends_on = [
    aws_eip.EipNatGWZoneA,
    aws_subnet.PublicSubnetA
  ]

  allocation_id = aws_eip.EipNatGWZoneA.id
  subnet_id     = aws_subnet.PublicSubnetA.id

  tags = {
    "Name"     = "${var.STACK_NAME}-NAT-GW-A"
    "StackEnv" = var.STACK_NAME
  }
}

# CREATE ELASTIC IP NAT GW ZONE B
resource "aws_eip" "EipNatGWZoneB" {
  vpc = true
  tags = {
    "Name"     = "${var.STACK_NAME}-EIP-NAT-B"
    "StackEnv" = var.STACK_NAME
  }
}

# CREATE NAT GATEWAY AND ASSOCITATE TO SUBNET PUBLIC IN ZONE B
resource "aws_nat_gateway" "NatGWZoneB" {
  depends_on = [
    aws_eip.EipNatGWZoneB,
    aws_subnet.PublicSubnetB
  ]

  allocation_id = aws_eip.EipNatGWZoneB.id
  subnet_id     = aws_subnet.PublicSubnetB.id

  tags = {
    "Name"     = "${var.STACK_NAME}-NAT-GW-B"
    "StackEnv" = var.STACK_NAME
  }
}


# CREATE PRIVATE ROUTE TABLE (ROUTE TABLE FOR EACH NAT)
resource "aws_route_table" "PrivateRouteTableZoneA" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-route-table-private-zone-a"
    "StackEnv" = var.STACK_NAME
  }
}

# Private Route NAT GW
resource "aws_route" "privateRouteNatZoneA" {
  depends_on = [
    aws_route_table.PrivateRouteTableZoneA,
    aws_nat_gateway.NatGWZoneA
  ]
  route_table_id         = aws_route_table.PrivateRouteTableZoneA.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NatGWZoneA.id
}

resource "aws_route_table" "PrivateRouteTableZoneB" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-route-table-private-zone-b"
    "StackEnv" = var.STACK_NAME
  }
}

resource "aws_route" "privateRouteNatZoneB" {
  depends_on = [
    aws_route_table.PrivateRouteTableZoneB,
    aws_nat_gateway.NatGWZoneB
  ]
  route_table_id         = aws_route_table.PrivateRouteTableZoneB.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NatGWZoneB.id
}

# CREATE PRIVATE SUBNETS
resource "aws_subnet" "PrivateSubnetA" {
  availability_zone = "${var.AWS_REGION}a"
  cidr_block        = var.CIDR_BLOCK_SUBNET_PRIVATE_A
  vpc_id            = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-A private"
    "Reach"    = "private"
    "StackEnv" = var.STACK_NAME
  }
}

resource "aws_subnet" "PrivateSubnetB" {
  availability_zone = "${var.AWS_REGION}b"
  cidr_block        = var.CIDR_BLOCK_SUBNET_PRIVATE_B
  vpc_id            = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-B private"
    "Reach"    = "private"
    "StackEnv" = var.STACK_NAME
  }
}


# ASSOCIATE ROUTE TABLE
resource "aws_route_table_association" "PrivateSubnetARouteTableAssociation" {
  subnet_id      = aws_subnet.PrivateSubnetA.id
  route_table_id = aws_route_table.PrivateRouteTableZoneA.id
}


resource "aws_route_table_association" "PrivateSubnetBRouteTableAssociation" {
  subnet_id      = aws_subnet.PrivateSubnetB.id
  route_table_id = aws_route_table.PrivateRouteTableZoneB.id
}

# CREATE PUBLIC SUBNETS
resource "aws_subnet" "PublicSubnetA" {
  availability_zone       = "${var.AWS_REGION}a"
  cidr_block              = var.CIDR_BLOCK_SUBNET_PUBLIC_A
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-A public"
    "Reach"    = "public"
    "StackEnv" = var.STACK_NAME
  }
}

resource "aws_subnet" "PublicSubnetB" {
  availability_zone       = "${var.AWS_REGION}b"
  cidr_block              = var.CIDR_BLOCK_SUBNET_PUBLIC_B
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-B public"
    "Reach"    = "public"
    "StackEnv" = var.STACK_NAME
  }
}

# CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-Internet gateway"
    "StackEnv" = var.STACK_NAME
  }
}

# CREATE ROUTE TABLE PUBLIC
resource "aws_route_table" "RouteTablePublic" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-RouteTable-public"
    "StackEnv" = var.STACK_NAME
  }
}

# CREATE CONNECTION BETWEEN ROUTE TABLE AND SUBNET PUBLIC A
resource "aws_route_table_association" "RouteTableAssociationPublicA" {
  subnet_id      = aws_subnet.PublicSubnetA.id
  route_table_id = aws_route_table.RouteTablePublic.id
}

# CREATE CONNECTION BETWEEN ROUTE TABLE AND SUBNET PUBLIC B
resource "aws_route_table_association" "RouteTableAssociationPublicB" {
  subnet_id      = aws_subnet.PublicSubnetB.id
  route_table_id = aws_route_table.RouteTablePublic.id
}

# CREATE CONNECTION WITH ROUTE TABLE PUBLIC AND INTERNET GATEWAY
resource "aws_route" "RouteTablePublicInternetRoute" {
  route_table_id         = aws_route_table.RouteTablePublic.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.InternetGateway.id
}


# CREATE ACL PUBLIC
resource "aws_network_acl" "NetworkAclPublic" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    "Name"     = "${var.STACK_NAME}-ACL public"
    "StackEnv" = var.STACK_NAME
  }
}

# ASSOCIATE ACL WITH SUBNET PUBLIC A
resource "aws_network_acl_association" "SubnetNetworkAclAssociationAPublic" {
  depends_on = [
    aws_network_acl.NetworkAclPublic,
    aws_subnet.PublicSubnetA
  ]

  network_acl_id = aws_network_acl.NetworkAclPublic.id
  subnet_id      = aws_subnet.PublicSubnetA.id
}


# ASSOCIATE ACL WITH SUBNET PUBLIC B
resource "aws_network_acl_association" "SubnetNetworkAclAssociationBPublic" {
  depends_on = [
    aws_network_acl.NetworkAclPublic,
    aws_subnet.PublicSubnetB
  ]

  network_acl_id = aws_network_acl.NetworkAclPublic.id
  subnet_id      = aws_subnet.PublicSubnetB.id
}

# CREATE RULE FOR PUBLIC INGRESS
resource "aws_network_acl_rule" "NetworkAclEntryInPublicAllowAll" {
  depends_on = [
    aws_network_acl.NetworkAclPublic
  ]

  network_acl_id = aws_network_acl.NetworkAclPublic.id
  rule_number    = 99
  protocol       = -1
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
}

# CREATE RULE FOR PUBLIC OUTPUT
resource "aws_network_acl_rule" "NetworkAclEntryOutPublicAllowAll" {
  depends_on = [
    aws_network_acl.NetworkAclPublic
  ]

  network_acl_id = aws_network_acl.NetworkAclPublic.id
  rule_number    = 99
  protocol       = -1
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
}
