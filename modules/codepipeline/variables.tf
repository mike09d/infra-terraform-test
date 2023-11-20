variable "AWS_REGION" {
  description = "AWS region value"
  type        = string
}

variable "STACK_NAME" {
  description = "Stack name for tags"
  type        = string
}

variable "MICROSERVICES_CODE_PIPELINE" {
  description = "Microservices codepipelines values"
  type        = list(any)
}

variable "CODE_BUILD_COMPUTE_TYPE" {
  description = "Information about the compute resources the build project will use. Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE. BUILD_GENERAL1_SMALL is only valid if type is set to LINUX_CONTAINER. When type is set to LINUX_GPU_CONTAINER, compute_type must be BUILD_GENERAL1_LARGE"
  type        = string
}

variable "CODE_BUILD_IMAGE" {
  description = "Docker image to use for this build project. We can use a custom image from ECR private or images fromhttps://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  type        = string
}

variable "CODE_BUILD_PRIVILEGED_MODE" {
  description = "Whether to enable running the Docker daemon inside a Docker container"
  type        = bool
}

variable "CODE_BUILD_TYPE" {
  description = "Type of build environment to use for related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER"
  type        = string
}

variable "CODE_BUILD_IMAGE_PULL" {
  description = "type of credentials AWS CodeBuild uses to pull images in your build. Valid values: CODEBUILD, SERVICE_ROLE"
  type        = string
}

variable "CODE_BUILD_SOURCE_TYPE" {
  description = "Type of repository that contains the source code to be built. Valid values: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3, NO_SOURCE"
  type        = string
}

variable "CODE_BUILD_ARTIFACT_TYPE" {
  description = "Build output artifact's type. Valid values: CODEPIPELINE, NO_ARTIFACTS, S3"
  type        = string
}

variable "CODE_BUILD_TIMEOUT" {
  description = "Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. The default is 60 minutes"
  type        = string 
}

variable "CODE_BUILD_CONCURRENT_LIMIT" {
  description = "Specify a maximum number of concurrent builds for the project. The value specified must be greater than 0 and less than the account concurrent running builds limit."
  type        = number
}

variable "VPC_ID" {
  description = "VPC id value"
  type        = string 
}

variable "PRIVATE_SUBNETS" {
  description = "Private subnets id"
  type        = list(string)
}

variable "S3_DEPLOYMENTS_BUCKET_ARN" {
  description = "S3 bucket deployment ARN"
  type        = string
}

variable "S3_DEPLOYMENTS_BUCKET_NAME" {
  description = "S3 bucket deployment ARN"
  type        = string
}

variable "CIDR_BLOCK_VPC" {
  description = "cidr_block value for VPC"
  type        = string
}
