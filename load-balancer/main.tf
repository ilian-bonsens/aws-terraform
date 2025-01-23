# Provider AWS
provider "aws" {
  region = var.aws_region
}

# VPC par défaut
data "aws_vpc" "default" {
  default = true
}

# Sous-réseaux dans la VPC pour le Load Balancer
data "aws_subnet" "subnet_az1" {
  id = "subnet-03a0aa7c5a73c1046"
}

data "aws_subnet" "subnet_az2" {
  id = "subnet-02c96f225e71ee9b1"
}

data "aws_subnet" "subnet_az3" {
  id = "subnet-04719bfcdf7da100a"
}

# Groupe de sécurité pour les instances
resource "aws_security_group" "security-group-vps" {
  name        = var.security_group_name
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.security-group-alb.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.security-group-alb.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# Groupe de sécurité pour le Load Balancer
resource "aws_security_group" "security-group-alb" {
  name        = "security-group-alb"
  description = "Security group for Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security-group-alb"
  }
}

# Load Balancer (ALB)
resource "aws_lb" "load_balancer" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security-group-alb.id]
  subnets            = [
    data.aws_subnet.subnet_az1.id,
    data.aws_subnet.subnet_az2.id,
    data.aws_subnet.subnet_az3.id
  ]

  enable_http2 = true

  enable_deletion_protection = false

  tags = {
    Name = "my-load-balancer"
  }
}

# Groupe cible pour les instances
resource "aws_lb_target_group" "target_group" {
  name     = "groupe-cible-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  stickiness {
    type             = "lb_cookie"
    enabled          = true
    cookie_duration  = 43200
  }
}

# Attacher les instances au groupe cible
resource "aws_lb_target_group_attachment" "instances_attachment" {
  count                = var.instance_count
  target_group_arn     = aws_lb_target_group.target_group.arn
  target_id            = aws_instance.ec2_instances[count.index].id
  port                 = 80
}

# Load Balancer listener HTTPS (port 443)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.ssl_certificate_arn
}

# Load Balancer listener HTTP (port 80) avec redirection vers HTTPS
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"
    }
  }
}

# Création des instances EC2
resource "aws_instance" "ec2_instances" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  vpc_security_group_ids = [aws_security_group.security-group-vps.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "${var.webpage_content}" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "webserver-${count.index + 1}"
  }
}