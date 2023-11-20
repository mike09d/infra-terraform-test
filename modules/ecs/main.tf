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
    key = "ECS"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.AWS_REGION
}

module "ecs" {
  source = "../../resources/ECS"
  AWS_REGION = var.AWS_REGION
  STACK_NAME = var.STACK_NAME
  vpc_id = var.vpc_id
  private_subnets = var.private_subnets
}


