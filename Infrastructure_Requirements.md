# Project Information

| Field                  | Value              |
| ---------------------- | ------------------ |
| Project Name           | fastapi-demo       |
| Project ID             | cloudteam-490409   |
| Cloud Provider         | google             |
| Region                 | us-east1           |
| Environment            | dev                |
| Deployment Platform    | Cloud Run          |
| Architecture Type      | backend            |
| Application Exposure   | Public             |
| Resource Naming Prefix | fastapi-demo-dev   |

# 2. Network Layer Requirement

## 2.1 Virtual Private Cloud (VPC)

| Field                | Value             |
| -------------------- | ----------------- |
| VPC Name             | fastapi-demo-vpc  |
| Network Mode         | Custom            |
| IP Version           | IPv4              |
| Cloud Run VPC Access | Direct VPC Egress |

---

## 2.2 Subnetwork Configuration

| Subnetwork Name | Subnet Type | Region   | CIDR Block  |
| --------------- | ----------- | -------- | ----------- |
| app-subnet      | Private     | us-east1 | 10.0.0.0/24 |

---

## 2.3 Internet Connectivity

| Field                  | Value |
| ---------------------- | ----- |
| Public Application     | Yes   |
| External Load Balancer | Yes   |
| Direct Public IP       | No    |
| Cloud NAT Enabled      | No    |

# 3. Security Layer Requirement

## 3.1 IAM Service Account & Permissions

| Service Account Name | Attached Service  | Permissions Required                          |
| -------------------- | ----------------- | --------------------------------------------- |
| fastapi-demo-run-sa  | Cloud Run Service | Application-specific Google Cloud permissions |
| fastapi-demo-run-sa  | Cloud Run Service | Cloud Logging                                 |

# 4. Container Platform Requirement

## 4.1 Cloud Run Configuration

| Field                 | Value                             |
| --------------------- | --------------------------------- |
| Service Name          | fastapi-demo-service              |
| Region                | us-east1                          |
| Platform              | Cloud Run                         |
| CPU Architecture      | x86_64                            |
| Ingress               | Internal and Cloud Load Balancing |
| Authentication        | Public                            |
| Execution Environment | Second Generation                 |
| Service Account       | fastapi-demo-run-sa               |

---

## 4.2 Backend Service Configuration

| Field                  | Value                |
| ---------------------- | -------------------- |
| Service Name           | fastapi-demo-service |
| Deployment Type        | Cloud Run            |
| Minimum Instances      | 1                    |
| Maximum Instances      | 1                    |
| Service Exposure       | Public               |
| Load Balancer Attached | Yes                  |

---

## 4.3 Container Runtime Configuration

| Container Port | CPU   | Memory | Read Only Root Filesystem | Container Restart Policy |
| -------------- | ----- | ------ | ------------------------- | ------------------------ |
| 8000           | 1 CPU | 512 Mi | No                        | Always                   |

---

## 4.4 Health Check Configuration

| Field                           | Value          |
| ------------------------------- | -------------- |
| Health Check Enabled            | Yes            |
| Health Check Type               | Liveness Probe |
| Health Check Path               | /health        |
| Health Check Port               | 8000           |
| Health Check Protocol           | HTTP           |
| Health Check Interval (Seconds) | 30             |

# 5. Load Balancing & Traffic Layer Requirement

## 5.1 Load Balancer Configuration

| Field              | Value                              |
| ------------------ | ---------------------------------- |
| Load Balancer Type | External Application Load Balancer |
| Exposure Type      | Public                             |
| Scheme             | External                           |
| Associated Network | fastapi-demo-vpc                   |
| Attached Service   | fastapi-demo-service               |

---

## 5.2 Listener Configuration

| Listener Name | Protocol | Port | Default Action             |
| ------------- | -------- | ---- | -------------------------- |
| http-listener | HTTP     | 80   | Forward to Backend Service |

---

## 5.3 Backend Service Configuration

| Backend Service Name | Target Service       | Protocol | Target Port |
| -------------------- | -------------------- | -------- | ----------- |
| fastapi-demo-backend | fastapi-demo-service | HTTP     | 8000        |

---

## 5.4 Serverless Network Endpoint Group

| Field             | Value                |
| ----------------- | -------------------- |
| NEG Type          | Serverless           |
| Backend Type      | Cloud Run            |
| Cloud Run Service | fastapi-demo-service |
| Region            | us-east1             |

# 6. Logging Requirement

## 6.1 Logging Configuration

| Field            | Value         |
| ---------------- | ------------- |
| Logging Enabled  | Yes           |
| Logging Platform | Cloud Logging |
| Container Logs   | Enabled       |

# 7. Required Terraform Outputs

The infrastructure should return the following Terraform outputs:

* Application Load Balancer IP
* Cloud Run Service Name
* Cloud Run Service URL
