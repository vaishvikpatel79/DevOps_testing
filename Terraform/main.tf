locals {
  # Construct full ECR image URIs for every service from the service_tags map.
  # service_tags = { "app-service" = "v1", "product-service" = "v1", ... }
  # Resulting map: { "app-service" = "123456789012.dkr.ecr.us-east-1.amazonaws.com/app-service:v1", ... }
  service_images = {
    for service_name, tag in var.service_tags :
    service_name => "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.service_repositories[service_name]}:${tag}"
  }
}

# 1. VPC
resource "aws_vpc" "fastapi_demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = var.dns_resolution_enabled
  enable_dns_hostnames = var.dns_hostnames_enabled

  tags = {
    Name       = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 2. Public Subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.fastapi_demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name       = "${var.project_name}-${var.environment}-public-subnet-1"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 3. Public Subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.fastapi_demo_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name       = "${var.project_name}-${var.environment}-public-subnet-2"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  tags = {
    Name       = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 5. Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  tags = {
    Name       = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 6. Default route to IGW
resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# 7. Route Table Associations
resource "aws_route_table_association" "rta_public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rta_public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# 8. Security Groups
resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-${var.environment}-alb-sg"
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  ingress = []
  egress  = []

  tags = {
    Name       = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name   = "${var.project_name}-${var.environment}-ecs-sg"
  vpc_id = aws_vpc.fastapi_demo_vpc.id

  ingress = []
  egress  = []

  tags = {
    Name       = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 9. Security Group Rules
resource "aws_security_group_rule" "alb_ingress_http_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_ingress_from_alb_8000" {
  type                       = "ingress"
  from_port                  = 8000
  to_port                    = 8000
  protocol                   = "tcp"
  security_group_id          = aws_security_group.ecs_service_sg.id
  source_security_group_id   = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service_sg.id
}

# 10. Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "${var.project_name}-${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name       = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 11. Target Group (use target_type = "ip" for Fargate/awsvpc)
resource "aws_lb_target_group" "fastapi_demo_tg" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.fastapi_demo_vpc.id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name       = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 12. Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi_demo_tg.arn
  }

  tags = {
    Name       = "${var.project_name}-${var.environment}-http-listener"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 13. ECS Cluster
resource "aws_ecs_cluster" "fastapi_demo_cluster" {
  name = "${var.project_name}-${var.environment}-ecs-cluster"

  tags = {
    Name       = "${var.project_name}-${var.environment}-ecs-cluster"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 14. IAM role for task execution
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Name       = "${var.project_name}-${var.environment}-ecs-task-exec"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 15. Attach managed policies
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 16. CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "/ecs/${var.project_name}-${var.environment}"

  tags = {
    Name       = "/ecs/${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 17. ECS Task Definition (Fargate)
resource "aws_ecs_task_definition" "fastapi_demo_task" {
  family                   = "${var.project_name}-${var.environment}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = tostring(var.container_cpu)
  memory                   = tostring(var.container_memory)

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name  = "fastapi-demo-service"
      image = local.service_images["fastapi-demo-service"]
      cpu   = var.container_cpu
      memory = var.container_memory
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
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_task_logs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = var.project_name
        }
      }
    }
  ])

  tags = {
    Name       = "${var.project_name}-${var.environment}-task"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# 18. ECS Service
resource "aws_ecs_service" "fastapi_demo_service" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.fastapi_demo_cluster.id
  task_definition = aws_ecs_task_definition.fastapi_demo_task.arn
  desired_count   = var.desired_count

  launch_type = "FARGATE"

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

  tags = {
    Name       = "${var.project_name}-${var.environment}-service"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
