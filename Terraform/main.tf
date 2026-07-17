locals {
  # Construct full ECR image URIs for every service from the service_tags map.
  # service_tags = { "app-service" = "v1", "product-service" = "v1", ... }
  # Resulting map: { "app-service" = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app-service:v1", ... }
  service_images = {
    for service_name, tag in var.service_tags :
    service_name => "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${service_name}:${tag}"
  }
}

resource "aws_vpc" "fastapi_demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.fastapi_demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-1"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
  depends_on = [aws_vpc.fastapi_demo_vpc]
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.fastapi_demo_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
  depends_on = [aws_vpc.fastapi_demo_vpc]
}

resource "aws_internet_gateway" "fastapi_demo_igw" {
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
  depends_on = [aws_vpc.fastapi_demo_vpc]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
  depends_on = [aws_vpc.fastapi_demo_vpc, aws_internet_gateway.fastapi_demo_igw]
}

resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fastapi_demo_igw.id
  depends_on             = [aws_route_table.public_route_table, aws_internet_gateway.fastapi_demo_igw]
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_subnet.public_subnet_1, aws_route_table.public_route_table]
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_subnet.public_subnet_2, aws_route_table.public_route_table]
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-${var.environment}-alb-sg"
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
  depends_on = [aws_vpc.fastapi_demo_vpc]
}

resource "aws_security_group" "ecs_service_sg" {
  name   = "${var.project_name}-${var.environment}-ecs-sg"
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
  depends_on = [aws_vpc.fastapi_demo_vpc]
}

resource "aws_security_group_rule" "alb_ingress_http_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
  depends_on        = [aws_security_group.alb_sg]
}

resource "aws_security_group_rule" "alb_egress_all_to_ecs_sg" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.fastapi_demo_vpc.cidr_block]
  security_group_id = aws_security_group.alb_sg.id
  depends_on        = [aws_security_group.alb_sg, aws_vpc.fastapi_demo_vpc, aws_security_group.ecs_service_sg]
}

resource "aws_security_group_rule" "ecs_ingress_tcp_8000_from_alb" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_service_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  depends_on               = [aws_security_group.ecs_service_sg, aws_security_group.alb_sg]
}

resource "aws_security_group_rule" "ecs_egress_all_to_anywhere" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service_sg.id
  depends_on        = [aws_security_group.ecs_service_sg]
}

resource "aws_lb" "application_load_balancer" {
  name               = "${var.project_name}-${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  security_groups    = [aws_security_group.alb_sg.id]
  internal           = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
  depends_on = [aws_subnet.public_subnet_1, aws_subnet.public_subnet_2, aws_security_group.alb_sg]
}

resource "aws_lb_target_group" "fastapi_demo_tg" {
  name        = "${var.project_name}-${var.environment}-tg"
  target_type = "ip"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fastapi_demo_vpc.id

  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
  depends_on = [aws_vpc.fastapi_demo_vpc]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi_demo_tg.arn
  }

  depends_on = [aws_lb.application_load_balancer, aws_lb_target_group.fastapi_demo_tg]
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

resource "aws_ecr_repository" "fastapi_demo_ecr" {
  name = "${var.project_name}-${var.environment}-ecr"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecr"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-exec-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  depends_on = [aws_iam_role.ecs_task_execution_role]
}

resource "aws_cloudwatch_log_group" "fastapi_demo_log_group" {
  name = "/ecs/${var.project_name}-${var.environment}-service"

  tags = {
    Name        = "/ecs/${var.project_name}-${var.environment}-service"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_ecs_task_definition" "fastapi_demo_task_def" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu_units)
  memory                   = tostring(var.memory_mb)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "fastapi-demo-service"
      image     = local.service_images["fastapi-demo-service"]
      cpu       = var.cpu_units
      memory    = var.memory_mb
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
          "awslogs-group"         = aws_cloudwatch_log_group.fastapi_demo_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
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

  depends_on = [aws_iam_role.ecs_task_execution_role, aws_cloudwatch_log_group.fastapi_demo_log_group, aws_ecr_repository.fastapi_demo_ecr]
}

resource "aws_ecs_service" "fastapi_demo_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.fastapi_demo_cluster.id
  task_definition = aws_ecs_task_definition.fastapi_demo_task_def.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fastapi_demo_tg.arn
    container_name   = "fastapi-demo-service"
    container_port   = var.container_port
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-service"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }

  depends_on = [aws_ecs_cluster.fastapi_demo_cluster, aws_ecs_task_definition.fastapi_demo_task_def, aws_lb_target_group.fastapi_demo_tg, aws_lb.application_load_balancer, aws_security_group.ecs_service_sg, aws_subnet.public_subnet_1, aws_subnet.public_subnet_2]
}
