variable "AWS_REGION" {
  description = "AWS region value"
  type        = string
}

variable "STACK_NAME" {
  description = "Stack name for tags"
  type        = string
}

variable "MICROSERVICES_CODE_PIPELINE" {
  type = list(object({
    microserviceName             = string,
    buildSpecLocation            = string
    microserviceRepository       = string
    microserviceRepositoryBranch = string
    ecrRepositoryName            = optional(string)
    envs = optional(list(object({
      name  = string,
      type  = string,
      value = string,
    })))
  }))
  description = "Microservices codepipelines"
}

variable "CODE_BUILD_COMPUTE_TYPE" {
  type = string
  validation {
    condition = contains(["BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM", "BUILD_GENERAL1_LARGE", "BUILD_GENERAL1_2XLARGE"],
    var.CODE_BUILD_COMPUTE_TYPE)
    error_message = "Invalid value for CODE_BUILD_COMPUTE_TYPE"
  }
  description = "Information about the compute resources the build project will use. Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE. BUILD_GENERAL1_SMALL is only valid if type is set to LINUX_CONTAINER. When type is set to LINUX_GPU_CONTAINER, compute_type must be BUILD_GENERAL1_LARGE"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "CODE_BUILD_IMAGE" {
  type        = string
  description = "Docker image to use for this build project. We can use a custom image from ECR private or images fromhttps://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html"
  default     = "aws/codebuild/standard:6.0"
}

variable "CODE_BUILD_PRIVILEGED_MODE" {
  type        = bool
  description = "Whether to enable running the Docker daemon inside a Docker container"
  default     = true
}

variable "CODE_BUILD_TYPE" {
  type        = string
  description = "Type of build environment to use for related builds. Valid values: LINUX_CONTAINER, LINUX_GPU_CONTAINER, WINDOWS_CONTAINER (deprecated), WINDOWS_SERVER_2019_CONTAINER, ARM_CONTAINER"
  validation {
    condition = contains([
      "LINUX_CONTAINER",
      "LINUX_GPU_CONTAINER",
      "WINDOWS_SERVER_2019_CONTAINER",
      "ARM_CONTAINER"
    ], var.CODE_BUILD_TYPE)
    error_message = "Invalid value for CODE_BUILD_TYPE"
  }
  default = "LINUX_CONTAINER"
}

variable "CODE_BUILD_IMAGE_PULL" {
  type        = string
  description = "type of credentials AWS CodeBuild uses to pull images in your build. Valid values: CODEBUILD, SERVICE_ROLE"
  default     = "CODEBUILD"
  validation {
    condition = contains([
      "CODEBUILD",
      "SERVICE_ROLE"
    ], var.CODE_BUILD_IMAGE_PULL)
    error_message = "Invalid value for CODE_BUILD_IMAGE_PULL"
  }
}

variable "CODE_BUILD_SOURCE_TYPE" {
  type        = string
  description = "Type of repository that contains the source code to be built. Valid values: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3, NO_SOURCE"
  default     = "CODEPIPELINE"
  validation {
    condition = contains([
      "CODECOMMIT",
      "CODEPIPELINE",
      "GITHUB",
      "GITHUB_ENTERPRISE",
      "S3",
      "BITBUCKET",
      "NO_SOURCE"
    ], var.CODE_BUILD_SOURCE_TYPE)
    error_message = "Invalid value for CODE_BUILD_SOURCE_TYPE"
  }
}

variable "CODE_BUILD_ARTIFACT_TYPE" {
  type        = string
  description = "Build output artifact's type. Valid values: CODEPIPELINE, NO_ARTIFACTS, S3"
  default     = "CODEPIPELINE"
  validation {
    condition = contains([
      "CODEPIPELINE",
      "NO_ARTIFACTS",
    "S3"], var.CODE_BUILD_ARTIFACT_TYPE)
    error_message = "Invalid value for CODE_BUILD_ARTIFACT_TYPE"
  }
}

variable "CODE_BUILD_TIMEOUT" {
  type        = string
  description = "Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. The default is 60 minutes"
  default     = "60"
}

variable "CODE_BUILD_CONCURRENT_LIMIT" {
  type        = number
  description = "Specify a maximum number of concurrent builds for the project. The value specified must be greater than 0 and less than the account concurrent running builds limit."
  default     = 1
}

variable "VPC_ID" {
  type        = string
  description = "VPC id value"
}

variable "PRIVATE_SUBNETS" {
  type        = list(string)
  description = "Private subnets id"
}

variable "S3_DEPLOYMENTS_BUCKET_ARN" {
  type        = string
  description = "S3 bucket deployment ARN"
}

variable "S3_DEPLOYMENTS_BUCKET_NAME" {
  type        = string
  description = "S3 bucket deployment ARN"
}

variable "CIDR_BLOCK_VPC" {
  description = "cidr_block value for VPC"
  type        = string
}
