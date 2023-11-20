variable "AWS_REGION" {
  description = "AWS region value"
  type        = string
}

variable "STACK_NAME" {
  description = "Stack name for tags"
  type        = string
}

variable "CIDR_BLOCK_VPC" {
  description = "cidr_block value for VPC"
  type        = string
}

variable "CIDR_BLOCK_SUBNET_PRIVATE_A" {
  description = "cidr_block value for private subnet A"
  type        = string
}

variable "CIDR_BLOCK_SUBNET_PRIVATE_B" {
  description = "cidr_block value for private subnet B"
  type        = string
}

variable "CIDR_BLOCK_SUBNET_PUBLIC_A" {
  description = "cidr_block value for public subnet A"
  type        = string
}

variable "CIDR_BLOCK_SUBNET_PUBLIC_B" {
  description = "cidr_block value for private subnet B"
  type        = string
}
