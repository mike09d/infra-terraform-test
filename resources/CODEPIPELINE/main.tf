# DATA ACCOUNT ID
data "aws_caller_identity" "current" {}

# DYNAMIC LOCAL ENVS
locals {

  # GET PRIVATE SUBNETS ARNS
  privateSubnetsARN = distinct(flatten([
    for privateSubnet in var.PRIVATE_SUBNETS : "arn:aws:ec2:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:subnet/${privateSubnet}"
  ]))
}

# CREATE CODE BUILD
resource "aws_codebuild_project" "CodeBuild" {
  depends_on = [
    aws_iam_role.CodePipelineRole,
    aws_security_group.CodeBuildSecurityGroup
  ]

  # ITERATE FOR EACH CODE PIPELINES OBJ
  for_each = { for pipeline in var.MICROSERVICES_CODE_PIPELINE : pipeline.microserviceName => pipeline }

  name                   = "${each.value.microserviceName}-build"
  description            = "${each.value.microserviceName} Build Project"
  build_timeout          = var.CODE_BUILD_TIMEOUT #  Number of minutes
  concurrent_build_limit = var.CODE_BUILD_CONCURRENT_LIMIT

  # SERVICE ROLE FOR CODE BUILD
  service_role = aws_iam_role.CodePipelineRole.arn

  artifacts {
    type = var.CODE_BUILD_ARTIFACT_TYPE
  }

  environment {
    compute_type                = var.CODE_BUILD_COMPUTE_TYPE
    image                       = var.CODE_BUILD_IMAGE
    type                        = var.CODE_BUILD_TYPE
    image_pull_credentials_type = var.CODE_BUILD_IMAGE_PULL
    privileged_mode             = var.CODE_BUILD_PRIVILEGED_MODE

    # ENVS
    dynamic "environment_variable" {
      for_each = each.value.envs
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      status     = "ENABLED"
      group_name = "${each.value.microserviceName}-build-logs"
    }
  }

  source {
    type      = var.CODE_BUILD_SOURCE_TYPE
    buildspec = "${var.S3_DEPLOYMENTS_BUCKET_ARN}/deployments-config-templates/${each.value.buildSpecLocation}"
  }

  vpc_config {
    vpc_id             = var.VPC_ID
    subnets            = var.PRIVATE_SUBNETS
    security_group_ids = [aws_security_group.CodeBuildSecurityGroup.id]
  }

  tags = {
    "Name"     = "${each.value.microserviceName}-build"
    "StackEnv" = var.STACK_NAME
  }
}

# CREATE CODEBUILD SECURITY GROUP
resource "aws_security_group" "CodeBuildSecurityGroup" {
  description = "${var.STACK_NAME}-Codebuild-SG"
  vpc_id      = var.VPC_ID
  name        = "${var.STACK_NAME}-Codebuild-SG"
  tags = {
    "Name"     = "${var.STACK_NAME}-Codebuild-SG"
    "StackEnv" = var.STACK_NAME
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.CIDR_BLOCK_VPC]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# CREATE CODE PIPELINE
resource "aws_codepipeline" "codepipeline" {
  depends_on = [
    aws_iam_role.CodePipelineRole,
    aws_codebuild_project.CodeBuild
  ]

  # Iterate each pipeline obj value
  for_each = { for pipeline in var.MICROSERVICES_CODE_PIPELINE : pipeline.microserviceName => pipeline }

  name     = "${each.value.microserviceName}-pipeline"
  role_arn = aws_iam_role.CodePipelineRole.arn

  artifact_store {
    location = var.S3_DEPLOYMENTS_BUCKET_NAME
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId = each.value.microserviceRepository       // "my-organization/example"
        BranchName       = each.value.microserviceRepositoryBranch /// "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${each.value.microserviceName}-build"
        # EnvironmentVariables = jsonencode(each.value.envs)
      }
    }
  }

  tags = {
    "Name"     = "${each.value.microserviceName}-Codepipeline"
    "StackEnv" = var.STACK_NAME
  }
}

#  CREATE CODEPIPELINE ROLE
resource "aws_iam_role" "CodePipelineRole" {
  name = "${var.STACK_NAME}-CodePipeline-Role"
  tags = {
    "Name"     = "${var.STACK_NAME}-CodePipeline-Role",
    "StackEnv" = var.STACK_NAME
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# ATTACH POLICY ROLES
resource "aws_iam_role_policy" "CodePipelinePolicies" {
  name = "codepipeline-policies"
  depends_on = [
    aws_iam_role.CodePipelineRole
  ]
  policy = jsonencode(
    {
      Statement = [
        {
          "Sid" : "ECRAccess",
          "Effect" : "Allow",
          "Action" : [
            "ecr:GetRegistryPolicy",
            "ecr:DescribeRegistry",
            "ecr:DescribePullThroughCacheRules",
            "ecr:GetAuthorizationToken",
            "ecr:PutRegistryScanningConfiguration",
            "ecr:DeleteRegistryPolicy",
            "ecr:CreatePullThroughCacheRule",
            "ecr:DeletePullThroughCacheRule",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer",
            "ecr:PutRegistryPolicy",
            "ecr:GetRegistryScanningConfiguration",
            "ecr:PutReplicationConfiguration",
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ],
          "Resource" : "*",
        },
        {
          "Sid" : "GetAuthorizationToken",
          "Effect" : "Allow",
          "Action" : [
            "ecr:GetAuthorizationToken",
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "aws:RequestedRegion" : var.AWS_REGION
            }
          }
        },
        {
          "Sid" : "GetSecretManager",
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : var.SECRETS_MANAGER_ARN,
        },
        {
          "Sid" : "CodeBuildEC2",
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs"
          ],
          "Resource" : "*"
          "Condition" : {
            "StringEquals" : {
              "aws:RequestedRegion" : var.AWS_REGION
            }
          }
        },
        {
          "Sid" : "CodeBuildNetWorkInterfaces",
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterfacePermission"
          ],
          "Resource" : [
            "arn:aws:ec2:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:network-interface/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "ec2:Subnet" : local.privateSubnetsARN
              "ec2:AuthorizedService" : "codebuild.amazonaws.com"
            }
          }
        },
        {
          "Sid" : "Logs",
          "Effect" : "Allow",
          "Resource" : "*"
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Condition" : {
            "StringEquals" : {
              "aws:RequestedRegion" : var.AWS_REGION
            }
          }
        },
        {
          "Sid" : "KMSAccess",
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "aws:RequestedRegion" : var.AWS_REGION
            }
          }
        },
        {
          "Sid" : "S3DeploymentAccess",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetBucketVersioning",
            "s3:GetObjectVersion"
          ],
          "Resource" : [
            "${var.S3_DEPLOYMENTS_BUCKET_ARN}",
            "${var.S3_DEPLOYMENTS_BUCKET_ARN}/*"
          ],
          "Condition" : {
            "StringEquals" : {
              "aws:RequestedRegion" : var.AWS_REGION
            }
          }
        },
        {
          "Sid" : "codebuildAccess",
          "Effect" : "Allow",
          "Action" : [
            "codebuild:StartBuild",
            "codebuild:BatchGetBuilds"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "aws:RequestedRegion" : var.AWS_REGION
            }
          }
        }
      ]
      Version = "2012-10-17"
    }
  )
  role = aws_iam_role.CodePipelineRole.id
}

resource "aws_codestarconnections_connection" "github_connection" {
  name          = "${var.STACK_NAME}-github-connection"
  provider_type = "GitHub"
}
