terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24.0"
    }
  }
  required_version = ">= 0.14.9"
  backend s3 {
    bucket = "test-mike-devops-state"
    key = "networking"
    region = "us-east-2"
  }
  
}

provider "aws" {
  region = var.AWS_REGION
}

module "vpc" {
  source = "../../resources/VPC"
  AWS_REGION = var.AWS_REGION
  STACK_NAME = var.STACK_NAME
  CIDR_BLOCK_VPC = var.CIDR_BLOCK_VPC
  CIDR_BLOCK_SUBNET_PRIVATE_A = var.CIDR_BLOCK_SUBNET_PRIVATE_A
  CIDR_BLOCK_SUBNET_PRIVATE_B = var.CIDR_BLOCK_SUBNET_PRIVATE_B
  CIDR_BLOCK_SUBNET_PUBLIC_A = var.CIDR_BLOCK_SUBNET_PUBLIC_A
  CIDR_BLOCK_SUBNET_PUBLIC_B = var.CIDR_BLOCK_SUBNET_PUBLIC_B
}


