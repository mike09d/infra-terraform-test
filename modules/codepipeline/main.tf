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

module "codepipeline" {
    source = "../../resources/CODEPIPELINE"
    AWS_REGION = var.AWS_REGION
    STACK_NAME = var.STACK_NAME
    MICROSERVICES_CODE_PIPELINE =  var.MICROSERVICES_CODE_PIPELINE
    CODE_BUILD_COMPUTE_TYPE = var.CODE_BUILD_COMPUTE_TYPE
    CODE_BUILD_IMAGE = var.CODE_BUILD_IMAGE
    CODE_BUILD_PRIVILEGED_MODE = var.CODE_BUILD_PRIVILEGED_MODE
    CODE_BUILD_TYPE = var.CODE_BUILD_TYPE
    CODE_BUILD_IMAGE_PULL = var.CODE_BUILD_IMAGE_PULL
    CODE_BUILD_SOURCE_TYPE = var.CODE_BUILD_SOURCE_TYPE
    CODE_BUILD_ARTIFACT_TYPE = var.CODE_BUILD_ARTIFACT_TYPE
    CODE_BUILD_TIMEOUT = var.CODE_BUILD_TIMEOUT
    CODE_BUILD_CONCURRENT_LIMIT = var.CODE_BUILD_CONCURRENT_LIMIT
    VPC_ID = var.VPC_ID
    S3_DEPLOYMENTS_BUCKET_ARN = var.S3_DEPLOYMENTS_BUCKET_ARN
    S3_DEPLOYMENTS_BUCKET_NAME = var.S3_DEPLOYMENTS_BUCKET_NAME
    CIDR_BLOCK_VPC = var.CIDR_BLOCK_VPC
}


