# ID SUBNETS
output "VPC_ID" { value = aws_vpc.VPC.id }
output "SUBNET_PRIVATE_A" { value = aws_subnet.PrivateSubnetA.id }
output "SUBNET_PRIVATE_B" { value = aws_subnet.PrivateSubnetB.id }
output "SUBNET_PUBLIC_A" { value = aws_subnet.PublicSubnetA.id }
output "SUBNET_PUBLIC_B" { value = aws_subnet.PublicSubnetB.id }

# ARN SUBNETS
output "SUBNET_PRIVATE_A_ARN" { value = aws_subnet.PrivateSubnetA.arn }
output "SUBNET_PRIVATE_B_ARN" { value = aws_subnet.PrivateSubnetB.arn }
output "SUBNET_PUBLIC_A_ARN" { value = aws_subnet.PublicSubnetA.arn }
output "SUBNET_PUBLIC_B_ARN" { value = aws_subnet.PublicSubnetB.arn }


# VPC VALUES
output "VPC_PRIVATE_ROUTE_TABLE_ZONE_A_ID" { value = aws_route_table.PrivateRouteTableZoneA.id }
output "VPC_PRIVATE_ROUTE_TABLE_ZONE_B_ID" { value = aws_route_table.PrivateRouteTableZoneB.id }
output "VPC_PUBLIC_ROUTE_TABLE_ID" { value = aws_route_table.RouteTablePublic.id }
output "CIDR_BLOCK_SUBNET_PRIVATE_A" { value = var.CIDR_BLOCK_SUBNET_PRIVATE_A }
output "CIDR_BLOCK_SUBNET_PRIVATE_B" { value = var.CIDR_BLOCK_SUBNET_PRIVATE_B }
output "CIDR_BLOCK_SUBNET_PUBLIC_A" { value = var.CIDR_BLOCK_SUBNET_PUBLIC_A }
output "CIDR_BLOCK_SUBNET_PUBLIC_B" { value = var.CIDR_BLOCK_SUBNET_PUBLIC_B }
