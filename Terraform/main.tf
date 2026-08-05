locals {
  # Construct full ECR image URIs for every service from the service_tags map.
  # service_tags = { "app-service" = "v1", "product-service" = "v1", ... }
  # Resulting map: { "app-service" = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app-service:v1", ... }
  service_images = {
    for service_name, tag in var.service_tags :
    service_name => "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.service_repositories[service_name]}:${tag}"
  }
}

resource "aws_vpc" "fastapi_demo_dev_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_subnet" "fastapi_demo_public_subnet_1" {
  vpc_id                  = aws_vpc.fastapi_demo_dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-pubsub1"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_subnet" "fastapi_demo_public_subnet_2" {
  vpc_id                  = aws_vpc.fastapi_demo_dev_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-pubsub2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_internet_gateway" "fastapi_demo_igw" {
  vpc_id = aws_vpc.fastapi_demo_dev_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_route_table" "fastapi_demo_public_rt" {
  vpc_id = aws_vpc.fastapi_demo_dev_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_route" "fastapi_demo_public_rt_default_route" {
  route_table_id         = aws_route_table.fastapi_demo_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fastapi_demo_igw.id
}

resource "aws_route_table_association" "fastapi_demo_pubsub1_assoc" {
  subnet_id      = aws_subnet.fastapi_demo_public_subnet_1.id
  route_table_id = aws_route_table.fastapi_demo_public_rt.id
}

resource "aws_route_table_association" "fastapi_demo_pubsub2_assoc" {
  subnet_id      = aws_subnet.fastapi_demo_public_subnet_2.id
  route_table_id = aws_route_table.fastapi_demo_public_rt.id
}

resource "aws_security_group" "fastapi_demo_alb_sg" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.fastapi_demo_dev_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_security_group" "fastapi_demo_ecs_service_sg" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.fastapi_demo_dev_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_security_group_rule" "fastapi_demo_alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.fastapi_demo_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP from anywhere"
}

resource "aws_security_group_rule" "fastapi_demo_alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fastapi_demo_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic from ALB"
}

resource "aws_security_group_rule" "fastapi_demo_ecs_ingress_8000" {
  type                         = "ingress"
  from_port                    = 8000
  to_port                      = 8000
  protocol                     = "tcp"
  security_group_id            = aws_security_group.fastapi_demo_ecs_service_sg.id
  source_security_group_id     = aws_security_group.fastapi_demo_alb_sg.id
  description                  = "Allow ALB to reach ECS tasks on 8000"
}

resource "aws_security_group_rule" "fastapi_demo_ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.fastapi_demo_ecs_service_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic from ECS tasks"
}

resource "aws_lb_target_group" "fastapi_demo_tg" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.container_port
  protocol    = var.health_check_protocol
  target_type = "ip"
  vpc_id      = aws_vpc.fastapi_demo_dev_vpc.id

  health_check {
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    healthy_threshold   = var.healthy_threshold_count
    unhealthy_threshold = var.unhealthy_threshold_count
    interval            = var.health_check_interval_seconds
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_lb" "fastapi_demo_alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.fastapi_demo_public_subnet_1.id, aws_subnet.fastapi_demo_public_subnet_2.id]
  security_groups    = [aws_security_group.fastapi_demo_alb_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_lb_listener" "fastapi_demo_http_listener" {
  load_balancer_arn = aws_lb.fastapi_demo_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi_demo_tg.arn
  }
}

resource "aws_cloudwatch_log_group" "fastapi_demo_ecs_log_group" {
  name = "/ecs/${var.project_name}-${var.environment}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-loggroup"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_iam_role" "fastapi_demo_task_execution_role" {
  name = "${var.project_name}-${var.environment}-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-task-exec-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_iam_role_policy_attachment" "fastapi_demo_task_execution_role_attachment" {
  role       = aws_iam_role.fastapi_demo_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "fastapi_demo_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_ecs_task_definition" "fastapi_demo_task_def" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.container_cpu)
  memory                   = tostring(var.container_memory)
  execution_role_arn       = aws_iam_role.fastapi_demo_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "fastapi-demo-service"
      image = local.service_images["fastapi-demo-service"]
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.fastapi_demo_ecs_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = var.project_name
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-task-def"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_ecs_service" "fastapi_demo_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.fastapi_demo_cluster.id
  task_definition = aws_ecs_task_definition.fastapi_demo_task_def.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    awsvpc_configuration {
      subnets         = [aws_subnet.fastapi_demo_public_subnet_1.id, aws_subnet.fastapi_demo_public_subnet_2.id]
      security_groups = [aws_security_group.fastapi_demo_ecs_service_sg.id]
      assign_public_ip = "ENABLED"
    }
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fastapi_demo_tg.arn
    container_name   = "fastapi-demo-service"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.fastapi_demo_http_listener]

  tags = {
    Name        = "${var.project_name}-${var.environment}-service"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}
