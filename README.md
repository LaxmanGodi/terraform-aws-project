# AWS Infrastructure as Code with Terraform

This project demonstrates how to deploy a **scalable**, **highly available**, and **secure** web application architecture on AWS using Terraform.

---

## 🏗️ Architecture Overview

The infrastructure is designed for **high availability** by spreading resources across multiple **Availability Zones (AZs)** and ensuring **secure communication** through tiered security groups.

### Key Architecture Features

| Feature | Description |
|---------|-------------|
| **High Availability** | Resources deployed across multiple Availability Zones |
| **Security** | Tiered security groups with least privilege model |
| **Scalability** | ALB-based architecture with multiple web servers |
| **Automation** |_userdata.sh scripts for automatic instance provisioning |

The EC2 instances are protected by a security group that only accepts traffic from the **Load Balancer's security group**, ensuring they are not directly exposed to the internet.

![Architecture Diagram](AWS_Terraform_Infra.jpg)

---

## 📂 Project Structure

This repository contains the following essential files:

| File | Description |
|------|-------------|
| `main.tf` | Core infrastructure definition (VPC, Subnets, EC2, ALB, and Security Groups) |
| `provider.tf` | AWS provider configuration and version requirements |
| `variables.tf` | Configuration variables (e.g., CIDR blocks) |
| `userdata.sh` | Provisioning script for webserver1 |
| `userdata1.sh` | Provisioning script for webserver2 |
| `AWS_Terraform_Infra.jpg` | Architecture diagram of the deployed infrastructure |

> **Note:** Terraform state files (.tfstate) are excluded from this repository for security and best practices.

---

## 🚀 Getting Started

### Prerequisites

- ✅ **Terraform** installed (v1.0+)
- ✅ **AWS CLI** configured with appropriate credentials
- ✅ An **AWS Key Pair** named `vpc_demo` exists in your AWS account

### Deployment Steps

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Preview the changes:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply -auto-approve
   ```

---

## 🛠️ Security Architecture

We utilize a **"Least Privilege"** model with the following security measures:

- **Tiered Security Groups:** Traffic flows only through designated paths
- **EC2 Protection:** Web servers accept traffic only from the ALB security group
- **No Direct Internet Exposure:** EC2 instances are not directly accessible from the internet
- **Security Group Referencing:** Terraform manages dependencies through security group references

---

## 🔍 Troubleshooting

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| **504 Gateway Timeout** | Ensure the ALB security group has an outbound rule allowing traffic to the web server security group on **port 80** |
| **Unhealthy Targets** | Check the Target Group health in the AWS Console. Ensure your userdata script successfully creates the `/var/www/html/index.html` file |
| **Authentication Failure** | Verify your AWS Key Pair named `vpc_demo` exists and is properly configured |
| **Plan/Apply Errors** | Run `terraform init -upgrade` to refresh provider plugins |

---

## 📈 Learnings

This project provided hands-on experience in:

- ✅ Managing **resource dependencies** with Terraform
- ✅ Securing cloud architecture via **Security Group referencing**
- ✅ Automating instance configuration using **userdata scripts**
- ✅ Deploying **highly available** infrastructure across multiple AZs
- ✅ Implementing **least privilege** security models

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---
