locals {
  # Construct full ECR image URIs for every service from the service_tags map.
  # service_tags = { "app-service" = "v1", "product-service" = "v1", ... }
  # Resulting map: { "app-service" = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app-service:v1", ... }
  service_images = {
    for service_name, tag in var.service_tags :
    service_name => "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.service_repositories[service_name]}:${tag}"
  }
}

resource "aws_vpc" "fastapi-demo-dev_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_subnet" "fastapi-demo-dev_public_subnet_1" {
  vpc_id                  = aws_vpc.fastapi-demo-dev_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-1"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_subnet" "fastapi-demo-dev_public_subnet_2" {
  vpc_id                  = aws_vpc.fastapi-demo-dev_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_internet_gateway" "fastapi-demo-dev_igw" {
  vpc_id = aws_vpc.fastapi-demo-dev_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_route_table" "fastapi-demo-dev_public_rt" {
  vpc_id = aws_vpc.fastapi-demo-dev_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_route" "fastapi-demo-dev_public_rt_default_route" {
  route_table_id         = aws_route_table.fastapi-demo-dev_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fastapi-demo-dev_igw.id
}

resource "aws_route_table_association" "fastapi-demo-dev_public_rta_1" {
  subnet_id      = aws_subnet.fastapi-demo-dev_public_subnet_1.id
  route_table_id = aws_route_table.fastapi-demo-dev_public_rt.id
}

resource "aws_route_table_association" "fastapi-demo-dev_public_rta_2" {
  subnet_id      = aws_subnet.fastapi-demo-dev_public_subnet_2.id
  route_table_id = aws_route_table.fastapi-demo-dev_public_rt.id
}

resource "aws_security_group" "fastapi-demo-dev_alb_sg" {
  name   = "${var.project_name}-${var.environment}-alb-sg"
  vpc_id = aws_vpc.fastapi-demo-dev_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_security_group" "fastapi-demo-dev_ecs_sg" {
  name   = "${var.project_name}-${var.environment}-ecs-sg"
  vpc_id = aws_vpc.fastapi-demo-dev_vpc.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_security_group_rule" "fastapi-demo-dev_alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fastapi-demo-dev_alb_sg.id
}

resource "aws_security_group_rule" "fastapi-demo-dev_alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fastapi-demo-dev_alb_sg.id
}

resource "aws_security_group_rule" "fastapi-demo-dev_ecs_ingress_from_alb" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.fastapi-demo-dev_ecs_sg.id
  source_security_group_id = aws_security_group.fastapi-demo-dev_alb_sg.id
}

resource "aws_security_group_rule" "fastapi-demo-dev_ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fastapi-demo-dev_ecs_sg.id
}

resource "aws_lb" "fastapi-demo-dev_alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [aws_subnet.fastapi-demo-dev_public_subnet_1.id, aws_subnet.fastapi-demo-dev_public_subnet_2.id]
  security_groups    = [aws_security_group.fastapi-demo-dev_alb_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_lb_target_group" "fastapi-demo-dev_tg" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fastapi-demo-dev_vpc.id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = var.health_check_interval
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_lb_listener" "fastapi-demo-dev_listener_http" {
  load_balancer_arn = aws_lb.fastapi-demo-dev_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi-demo-dev_tg.arn
  }
}

resource "aws_cloudwatch_log_group" "fastapi-demo-dev_log_group" {
  name = "/ecs/${var.project_name}-${var.environment}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-log-group"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

data "aws_iam_policy_document" "task_execution_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fastapi-demo-dev_task_exec_role" {
  name               = "${var.project_name}-${var.environment}-task-exec-role"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-task-exec-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_iam_role_policy_attachment" "fastapi-demo-dev_task_exec_role_attachment" {
  role       = aws_iam_role.fastapi-demo-dev_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "fastapi-demo-dev_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_ecs_task_definition" "fastapi-demo-dev_task_def" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.container_cpu)
  memory                   = tostring(var.container_memory)
  execution_role_arn       = aws_iam_role.fastapi-demo-dev_task_exec_role.arn

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
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.fastapi-demo-dev_log_group.name
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

resource "aws_ecs_service" "fastapi-demo-dev_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.fastapi-demo-dev_cluster.id
  task_definition = aws_ecs_task_definition.fastapi-demo-dev_task_def.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.fastapi-demo-dev_public_subnet_1.id, aws_subnet.fastapi-demo-dev_public_subnet_2.id]
    security_groups = [aws_security_group.fastapi-demo-dev_ecs_sg.id]
    assign_public_ip = "ENABLED"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fastapi-demo-dev_tg.arn
    container_name   = "fastapi-demo-service"
    container_port   = var.container_port
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-service"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}
