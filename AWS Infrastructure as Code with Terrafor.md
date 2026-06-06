AWS Infrastructure as Code with Terraform
This project demonstrates how to deploy a scalable, highly available, and secure web application architecture on AWS using Terraform.

🏗️ Architecture Overview
The infrastructure is designed for high availability by spreading resources across multiple Availability Zones (AZs) and ensuring secure communication through tiered security groups.

📂 Project Structure
This repository contains the following essential files:

main.tf: The core infrastructure definition (VPC, Subnets, EC2, ALB, and Security Groups).

provider.tf: AWS provider configuration and version requirements.

variables.tf: Configuration variables (e.g., CIDR blocks).

userdata.sh: Provisioning script for webserver1.

userdata1.sh: Provisioning script for webserver2.

AWS Terraform Infra.jpg: Architecture diagram of the deployed infrastructure.

(Note: Terraform state files are excluded from this repository for security and best practices.)

🚀 Getting Started
Prerequisites
Terraform installed.

AWS CLI configured.

An AWS Key Pair named vpc_demo.

Deployment Steps
Initialize Terraform:

Bash
terraform init
Preview the changes:

Bash
terraform plan
Apply the configuration:

Bash
terraform apply -auto-approve
🛠️ Security Architecture
We utilize a "Least Privilege" model. The EC2 instances are protected by a security group that only accepts traffic from the Load Balancer's security group, ensuring they are not directly exposed to the internet.

🔍 Troubleshooting
504 Gateway Timeout: Ensure the ALB security group has an outbound rule allowing traffic to the web server security group on port 80.

Unhealthy Targets: Check the Target Group health in the AWS Console. Ensure your userdata script successfully creates the /var/www/html/index.html file.

📈 Learnings
This project provided hands-on experience in:

Managing resource dependencies with Terraform.

Securing cloud architecture via Security Group referencing.

Automating instance configuration using userdata