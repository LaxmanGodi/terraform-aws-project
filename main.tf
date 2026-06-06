# --- VPC CONFIGURATION ---
# Defines the main networking environment (VPC) that acts as an isolated network
resource "aws_vpc" "myvpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true # Enables DNS resolution within the VPC
  enable_dns_hostnames = true # Assigns public DNS names to instances with public IPs
  tags                 = { Name = "main-vpc" }
}

# --- SUBNET CONFIGURATION ---
# Public Subnet 1 in availability zone A for load balancer distribution
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # Instances get public IP automatically
  tags                    = { Name = "public-subnet-1" }
}

# Public Subnet 2 in availability zone B for high availability
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-2" }
}

# --- CONNECTIVITY ---
# Internet Gateway connects the VPC to the outside internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

# Route Table defines rules to direct traffic from subnets to the internet
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Association: Linking public subnet 1 to the route table for internet access
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

# Association: Linking public subnet 2 to the route table for internet access
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

# --- SECURITY ---
# Security Group for Load Balancer: Allows public traffic on HTTP (port 80)
resource "aws_security_group" "lb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_http" {
  security_group_id = aws_security_group.lb_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# FIX: Allow the Load Balancer to send traffic out to the instances
resource "aws_vpc_security_group_egress_rule" "alb_to_instances" {
  security_group_id            = aws_security_group.lb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.webSg.id
}

# Security Group for Instances: Restricts access to ONLY allow traffic from the Load Balancer
resource "aws_security_group" "webSg" {
  name   = "web-sg"
  vpc_id = aws_vpc.myvpc.id
}

# Ingress Rule: Allows incoming HTTP traffic only from the ALB security group
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb" {
  security_group_id            = aws_security_group.webSg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lb_sg.id
}

# Ingress Rule: Allows SSH access for administrative maintenance
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.webSg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Egress Rule: Allows instances to send traffic out (necessary for updates/software installation)
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.webSg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# --- STORAGE ---
# Creates an S3 bucket for project data storage
resource "aws_s3_bucket" "example" {
  bucket = "laxmangodi-terraform-2026-project"
}

# --- COMPUTE ---
# Deploys EC2 Instance 1 in Subnet 1
resource "aws_instance" "webserver1" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro"
  key_name               = "vpc_demo"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data_base64       = base64encode(file("userdata.sh")) # Provisioning script
}

# Deploys EC2 Instance 2 in Subnet 2
resource "aws_instance" "webserver2" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro"
  key_name               = "vpc_demo"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data_base64       = base64encode(file("userdata1.sh")) # Provisioning script
}

# --- LOAD BALANCER ---
# Application Load Balancer distributes incoming public traffic to instances
resource "aws_lb" "myalb" {
  name               = "my-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
}

# Target Group: Defines where the traffic should be sent
resource "aws_lb_target_group" "tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/" # Path checked by the ALB to determine if instance is healthy
  }
}

# Attachment: Binds Instance 1 to the Load Balancer target group
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

# Attachment: Binds Instance 2 to the Load Balancer target group
resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

# Listener: Listens for incoming traffic on port 80 and forwards to the target group
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

# Output: Provides the DNS URL to access the deployed application after apply
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
