variable "STACK_NAME" {
  description = "Stack name for tags"
  type        = string
}

variable "AWS_REGION" {
  description = "AWS region value"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "private_subnets" {
  description = "VPC ID private subnets"
  type        = list(any)
}
