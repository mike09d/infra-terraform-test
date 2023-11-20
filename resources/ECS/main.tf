# ALB security group. 
resource "aws_security_group" "Alb_security_group" {
  description = "ALB Security Group"
  vpc_id = var.vpc_id
  ingress {
    description      = "Allow from anyone on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "sg_ingress_rule_all_to_lb" {
  type	= "ingress"
  description = "Allow from anyone on port 80"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.Alb_security_group.id
}

# ALB-SG egress rule to ECS cluster security group.
resource "aws_security_group_rule" "sg_egress_rule_Alb_to_ecs_cluster" {
  type	= "egress"
  description = "Target group egress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = aws_security_group.Alb_security_group.id
  source_security_group_id = aws_security_group.ecs_security_group.id
}

# ECS cluster security group.
resource "aws_security_group" "ecs_security_group" {
  description = "ECS Security Group"
  vpc_id = var.vpc_id
  egress {
    description      = "Allow all outbound traffic by default"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# ECS cluster security group ingress from the load balancer.
resource "aws_security_group_rule" "sg_ingress_rule_ecs_cluster_from_Alb" {
  type	= "ingress"
  description = "Ingress from Load Balancer"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_security_group.id
  source_security_group_id = aws_security_group.Alb_security_group.id
}

# Create the internal application load balancer (ALB) in the private subnets.
resource "aws_lb" "ecs_alb" {
  load_balancer_type = "application"
  internal = true
  subnets = var.private_subnets
  security_groups = [aws_security_group.Alb_security_group.id]
}

# Create the ALB target group for ECS.
resource "aws_lb_target_group" "alb_ecs_tg" {
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

# Create the ALB listener with the target group.
resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ecs_tg.arn
  }
}

# Create the ECS Cluster and Fargate launch type service in the private subnets
resource "aws_ecs_cluster" "ecs_cluster" {
  name  = "${var.STACK_NAME}-ecs-cluster"
}

resource "aws_ecs_service" "ecs-service" {
  name            = "${var.STACK_NAME}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_taskdef.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 50
  enable_ecs_managed_tags = false
  health_check_grace_period_seconds = 60
  launch_type = "FARGATE"
  depends_on      = [aws_lb_target_group.alb_ecs_tg, aws_lb_listener.ecs_alb_listener]

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_ecs_tg.arn
    container_name   = "${var.STACK_NAME}-service-web"
    container_port   = 8000
  }

  network_configuration {
    security_groups = [aws_security_group.ecs_security_group.id]
    subnets = var.private_subnets
  }
}
resource "aws_ecs_task_definition" "ecs_taskdef" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "${var.STACK_NAME}-task-web"
      image     = "663336538240.dkr.ecr.us-east-2.amazonaws.com/test-mike-service1:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
    }
  ])
  cpu       = 512
  memory    = 1024
  execution_role_arn = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}
resource "aws_iam_role" "ecs_task_exec_role" {
  name = "ecs_task_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# Create the VPC Link configured with the private subnets. Security groups are kept empty here, but can be configured as required.
resource "aws_apigatewayv2_vpc_link" "vpclink_apigw_to_alb" {
  name        = "vpclink_apigw_to_alb"
  security_group_ids = []
  subnet_ids = var.private_subnets
}

# Create the API Gateway HTTP endpoint
resource "aws_apigatewayv2_api" "apigw_http_endpoint" {
  name          = "serverlessland-pvt-endpoint"
  protocol_type = "HTTP"
}

# Create the API Gateway HTTP_PROXY to private load balancer via the VPC Link.
resource "aws_apigatewayv2_integration" "apigw_integration" {
  api_id           = aws_apigatewayv2_api.apigw_http_endpoint.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.ecs_alb_listener.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb.id
  payload_format_version = "1.0"
  depends_on      = [aws_apigatewayv2_vpc_link.vpclink_apigw_to_alb, 
                    aws_apigatewayv2_api.apigw_http_endpoint, 
                    aws_lb_listener.ecs_alb_listener]
}

# API GW route with ANY method
resource "aws_apigatewayv2_route" "apigw_route" {
  api_id    = aws_apigatewayv2_api.apigw_http_endpoint.id
  route_key = "ANY /{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration.id}"
  depends_on  = [aws_apigatewayv2_integration.apigw_integration]
}

# Set a default stage
resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id = aws_apigatewayv2_api.apigw_http_endpoint.id
  name   = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.apigw_http_endpoint]
}