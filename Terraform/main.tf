locals {
  # Construct full ECR image URIs for every service from the service_tags map.
  # service_tags = { "app-service" = "v1", "product-service" = "v1", ... }
  # Resulting map: { "app-service" = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app-service:v1", ... }
  service_images = {
    for service_name, tag in var.service_tags :
    service_name => "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.service_repositories[service_name]}:${tag}"
  }
}

# VPC
resource "aws_vpc" "fastapi-demo-dev_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name       = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Public Subnet 1
resource "aws_subnet" "fastapi-demo-dev_public_subnet_1" {
  vpc_id                  = aws_vpc.fastapi-demo-dev_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name       = "${var.project_name}-${var.environment}-public-subnet-1"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Public Subnet 2
resource "aws_subnet" "fastapi-demo-dev_public_subnet_2" {
  vpc_id                  = aws_vpc.fastapi-demo-dev_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name       = "${var.project_name}-${var.environment}-public-subnet-2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "fastapi-demo-dev_igw" {
  vpc_id = aws_vpc.fastapi-demo-dev_vpc.id

  tags = {
    Name       = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Public Route Table (no inline routes; we will create aws_route separately)
resource "aws_route_table" "fastapi-demo-dev_public_rt" {
  vpc_id = aws_vpc.fastapi-demo-dev_vpc.id

  tags = {
    Name       = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Default route to internet gateway for public route table
resource "aws_route" "fastapi-demo-dev_public_rt_default_route" {
  route_table_id         = aws_route_table.fastapi-demo-dev_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fastapi-demo-dev_igw.id
}

# Route table associations
resource "aws_route_table_association" "fastapi-demo-dev_public_rta_subnet_1" {
  subnet_id      = aws_subnet.fastapi-demo-dev_public_subnet_1.id
  route_table_id = aws_route_table.fastapi-demo-dev_public_rt.id
}

resource "aws_route_table_association" "fastapi-demo-dev_public_rta_subnet_2" {
  subnet_id      = aws_subnet.fastapi-demo-dev_public_subnet_2.id
  route_table_id = aws_route_table.fastapi-demo-dev_public_rt.id
}

# Security Groups
resource "aws_security_group" "fastapi-demo-dev_alb_sg" {
  name   = "${var.project_name}-${var.environment}-alb-sg"
  vpc_id = aws_vpc.fastapi-demo-dev_vpc.id

  tags = {
    Name       = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "fastapi-demo-dev_ecs_service_sg" {
  name   = "${var.project_name}-${var.environment}-ecs-service-sg"
  vpc_id = aws_vpc.fastapi-demo-dev_vpc.id

  tags = {
    Name       = "${var.project_name}-${var.environment}-ecs-service-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# ALB Inbound HTTP from anywhere
resource "aws_security_group_rule" "fastapi-demo-dev_alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fastapi-demo-dev_alb_sg.id
}

# ALB Egress - allow all outbound (to internet / services)
resource "aws_security_group_rule" "fastapi-demo-dev_alb_egress_to_ecs" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fastapi-demo-dev_alb_sg.id
}

# ECS Ingress from ALB security group (allow ALB to reach container port)
resource "aws_security_group_rule" "fastapi-demo-dev_ecs_ingress_from_alb" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fastapi-demo-dev_ecs_service_sg.id
  source_security_group_id = aws_security_group.fastapi-demo-dev_alb_sg.id
}

# ECS Egress all to anywhere
resource "aws_security_group_rule" "fastapi-demo-dev_ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fastapi-demo-dev_ecs_service_sg.id
}

# Application Load Balancer
resource "aws_lb" "fastapi-demo-dev_alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [aws_subnet.fastapi-demo-dev_public_subnet_1.id, aws_subnet.fastapi-demo-dev_public_subnet_2.id]
  security_groups    = [aws_security_group.fastapi-demo-dev_alb_sg.id]

  tags = {
    Name       = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Target Group for Fargate (target_type = ip required for awsvpc)
resource "aws_lb_target_group" "fastapi-demo-dev_tg" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fastapi-demo-dev_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = var.health_check_interval_seconds
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = {
    Name       = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Listener for ALB
resource "aws_lb_listener" "fastapi-demo-dev_listener_http" {
  load_balancer_arn = aws_lb.fastapi-demo-dev_alb.arn
  port              = var.alb_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi-demo-dev_tg.arn
  }

  tags = {
    Name       = "${var.project_name}-${var.environment}-listener-http"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "fastapi-demo-dev_ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name       = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Attach AWS managed policy for ECS task execution (ECR pull, CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "fastapi-demo-dev_task_exec_role_attach" {
  role       = aws_iam_role.fastapi-demo-dev_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "fastapi-demo-dev_ecs_log_group" {
  name = "/ecs/${var.project_name}-${var.environment}/task"

  tags = {
    Name       = "/ecs/${var.project_name}-${var.environment}/task"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "fastapi-demo-dev_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name       = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# ECS Task Definition (Fargate)
resource "aws_ecs_task_definition" "fastapi-demo-dev_task_def" {
  family                   = "${var.project_name}-${var.environment}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.container_cpu)
  memory                   = tostring(var.container_memory)
  execution_role_arn       = aws_iam_role.fastapi-demo-dev_ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "fastapi-demo-service"
      image     = local.service_images["fastapi-demo-service"]
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.fastapi-demo-dev_ecs_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name       = "${var.project_name}-${var.environment}-task-def"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# ECS Service (Fargate) attached to ALB target group
resource "aws_ecs_service" "fastapi-demo-dev_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.fastapi-demo-dev_cluster.id
  task_definition = aws_ecs_task_definition.fastapi-demo-dev_task_def.arn
  desired_count   = var.desired_count

  network_configuration {
    subnets         = [aws_subnet.fastapi-demo-dev_public_subnet_1.id, aws_subnet.fastapi-demo-dev_public_subnet_2.id]
    security_groups = [aws_security_group.fastapi-demo-dev_ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fastapi-demo-dev_tg.arn
    container_name   = "fastapi-demo-service"
    container_port   = var.container_port
  }

  tags = {
    Name       = "${var.project_name}-${var.environment}-service"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
