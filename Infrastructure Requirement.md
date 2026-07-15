# Project Information

| Field | Value |
|---|---|
| Project Name | fastapi-demo |
| Cloud Provider | AWS |
| Region | us-east-1 |
| Environment | dev |
| Deployment Platform | ECS Fargate |
| Architecture Type | backend |
| Application Exposure | Public |
| Resource Naming Prefix | fastapi-demo-dev |
| AccountID | 220897588425 |

---

# 1. Network Layer Requirement

## 1.1 Virtual Private Cloud (VPC)

| Field | Value |
|---|---|
| VPC Name | fastapi-demo-vpc |
| CIDR Block | 10.0.0.0/16 |
| IP Version | IPv4 |
| DNS Resolution Enabled | Yes |
| DNS Hostnames Enabled | Yes |

---

## 1.2 Subnet Configuration

| Subnet Name | Subnet Type | Availability Zone | CIDR Block | Auto Assign Public IP |
|---|---|---|---|---|
| public-subnet-1 | public | us-east-1a | 10.0.1.0/24 | Yes |
| public-subnet-2 | public | us-east-1b | 10.0.2.0/24 | Yes |

---

## 1.3 Internet Connectivity

| Field | Value |
|---|---|
| Internet Gateway Enabled | Yes |
| NAT Gateway Enabled | No |

---

# 2. Security Layer Requirement

## 2.1 Security Group Configuration

| Security Group Name | Attached Service | Traffic Direction | Protocol | Port | Source / Destination |
|---|---|---|---|---|---|
| alb-sg | Application Load Balancer | Inbound | TCP | 80 | 0.0.0.0/0 |
| alb-sg | Application Load Balancer | Outbound | All | All | ecs-service-sg |
| ecs-service-sg | ECS Service | Inbound | TCP | 8000 | alb-sg |
| ecs-service-sg | ECS Service | Outbound | All | All | Anywhere |

---

## 2.2 IAM Roles & Permissions

| Role Name | Attached Service | Permissions Required |
|---|---|---|
| ecs-task-execution-role | ECS Task Execution | ECR Pull, CloudWatch Logs |

---

# 3. Compute Layer Requirement

## 3.1 Compute Platform Configuration

| Field | Value |
|---|---|
| Compute Platform | ECS Fargate |
| Container Registry | Amazon ECR |
| Launch Type | Fargate |
| Operating System | Linux |
| CPU Architecture | x86_64 |

---

## 3.2 Backend Service Configuration

| Field | Value |
|---|---|
| Service Name | fastapi-demo-service |
| Deployment Type | ECS Fargate |
| Desired Task Count | 1 |
| Service Exposure | Public |
| Attached Load Balancer | Yes |

---

## 3.3 Container Runtime Configuration

| Container Port | CPU Units | Memory (MB) | Read Only Root Filesystem | Container Restart Policy |
|---|---|---|---|---|
| 8000 | 256 | 512 | No | Always |

---

## 3.4 Health Check Configuration

| Field | Value |
|---|---|
| Health Check Enabled | Yes |
| Health Check Path | /health |
| Health Check Port | traffic-port |
| Health Check Protocol | HTTP |
| Healthy Threshold Count | 2 |
| Unhealthy Threshold Count | 3 |
| Health Check Interval (Seconds) | 30 |

---

# 4. Load Balancing & Traffic Layer Requirement

## 4.1 Load Balancer Configuration

| Field | Value |
|---|---|
| Load Balancer Type | Application Load Balancer |
| Exposure Type | Public |
| Scheme | Internet Facing |
| Associated Subnet Type | public |
| Attached Service | fastapi-demo-service |

---

## 4.2 Listener Configuration

| Listener Name | Protocol | Port | Default Action |
|---|---|---|---|
| http-listener | HTTP | 80 | Forward to Backend Target Group |

---

## 4.3 Target Group Configuration

| Target Group Name | Target Service | Protocol | Target Port | Health Check Path |
|---|---|---|---|---|
| fastapi-demo-tg | fastapi-demo-service | HTTP | 8000 | /health |

---

# Outputs Required

The infrastructure should return the following Terraform outputs:

- Application Load Balancer DNS
- ECS Cluster Name
- ECS Service Name
- ECS Task Definition ARN
- ECR Image URI
```
