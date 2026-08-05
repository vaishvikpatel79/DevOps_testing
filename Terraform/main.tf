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
resource "aws_vpc" "fastapi_demo_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# Public Subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.fastapi_demo_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.public_subnet_1_az
  map_public_ip_on_launch = var.public_subnet_auto_assign

  tags = {
    Name      = "${var.project_name}-${var.environment}-public-subnet-1"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.fastapi_demo_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.public_subnet_2_az
  map_public_ip_on_launch = var.public_subnet_auto_assign

  tags = {
    Name      = "${var.project_name}-${var.environment}-public-subnet-2"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  tags = {
    Name      = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  tags = {
    Name      = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# Route to Internet Gateway
resource "aws_route" "public_route_0_0_0_0" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate subnets with route table
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-${var.environment}-alb-sg"
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  description = "Security group for ALB"

  tags = {
    Name      = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name   = "${var.project_name}-${var.environment}-ecs-sg"
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  description = "Security group for ECS tasks"

  tags = {
    Name      = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# ALB inbound HTTP from anywhere
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP from anywhere"
}

# ALB egress allow all (practical mapping for outbound to services)
resource "aws_security_group_rule" "alb_egress_to_ecs" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow all outbound from ALB"
}

# ECS ingress from ALB security group
resource "aws_security_group_rule" "ecs_ingress_from_alb" {
  type                        = "ingress"
  from_port                   = var.container_port
  to_port                     = var.container_port
  protocol                    = "tcp"
  security_group_id           = aws_security_group.ecs_service_sg.id
  source_security_group_id    = aws_security_group.alb_sg.id
  description                 = "Allow ALB to reach ECS tasks"
}

# ECS egress to anywhere
resource "aws_security_group_rule" "ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service_sg.id
  description       = "Allow ECS tasks to reach the internet"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = {
    Name      = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name      = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# CloudWatch Log Group for ECS tasks
resource "aws_cloudwatch_log_group" "ecs_task_log_group" {
  name = "/ecs/${var.project_name}-${var.environment}"

  tags = {
    Name      = "${var.project_name}-${var.environment}-loggroup"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "fastapi_demo_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name      = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# ALB Target Group for Fargate (target_type = "ip")
resource "aws_lb_target_group" "fastapi_demo_tg" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fastapi_demo_vpc.id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name      = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# HTTP Listener forwarding to target group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi_demo_tg.arn
  }
}

# ECS Task Definition (Fargate)
resource "aws_ecs_task_definition" "fastapi_demo_task" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu_units)
  memory                   = tostring(var.memory_mb)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name       = "fastapi-demo-service"
      image      = local.service_images["fastapi-demo-service"]
      essential  = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      readonlyRootFilesystem = var.read_only_root_filesystem
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name      = "${var.project_name}-${var.environment}-taskdef"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# ECS Service (Fargate) registered to ALB Target Group
resource "aws_ecs_service" "fastapi_demo_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.fastapi_demo_cluster.id
  task_definition = aws_ecs_task_definition.fastapi_demo_task.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fastapi_demo_tg.arn
    container_name   = "fastapi-demo-service"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http_listener]

  tags = {
    Name      = "${var.project_name}-${var.environment}-service"
    Environment = var.environment
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}
