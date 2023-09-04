#vpc
resource "aws_vpc" "land_tasker_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "landTasker"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.land_tasker_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone      = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.land_tasker_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone      = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.land_tasker_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.land_tasker_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_internet_gateway" "land_tasker_igw" {
  vpc_id = aws_vpc.land_tasker_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.land_tasker_vpc.id

  route {
    cidr_block = var.cidr_blocks_anywhere
    gateway_id = aws_internet_gateway.land_tasker_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_eip_1" {
  vpc = true
}

resource "aws_eip" "nat_eip_2" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
}

resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.land_tasker_vpc.id
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.land_tasker_vpc.id
}

resource "aws_route" "private_route_1" {
  route_table_id         = aws_route_table.private_route_table_1.id
  destination_cidr_block = var.cidr_blocks_anywhere
  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id
}

resource "aws_route" "private_route_2" {
  route_table_id         = aws_route_table.private_route_table_2.id
  destination_cidr_block = var.cidr_blocks_anywhere
  nat_gateway_id         = aws_nat_gateway.nat_gateway_2.id
}

resource "aws_route_table_association" "private_subnet_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table_association" "private_subnet_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

#alb
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.land_tasker_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = var.protocol
    cidr_blocks = [var.cidr_blocks_anywhere]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = var.protocol
    cidr_blocks = [var.cidr_blocks_anywhere]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks_anywhere]
  }
}

resource "aws_lb" "alb" {
  name               = "land-tasker-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "redirect"
    redirect {
      protocol       = "HTTPS"
      port           = "443"
      status_code    = "HTTP_301"
    }
  }
}

provider "aws" {
  region = var.region
  alias  = "us_east_1"
}

#create alb acm 
resource "aws_acm_certificate" "my_certificate" {
  domain_name               = var.r53_record_name
  validation_method         = "DNS"
  provider                  = aws.us_east_1
}

#add cname to r53
locals {
  domain_validation_options_list = tolist(aws_acm_certificate.my_certificate.domain_validation_options)
}

resource "aws_route53_record" "cname_record" {
  zone_id = var.r53_zone_id
  name    = local.domain_validation_options_list[0].resource_record_name
  type    = "CNAME"
  ttl     = 300
  records = [local.domain_validation_options_list[0].resource_record_value]
}

# Explicit dependency on the ACM certificate validation
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.my_certificate.arn
  validation_record_fqdns = [aws_route53_record.cname_record.fqdn]

  depends_on = [aws_acm_certificate.my_certificate]
}

#add a record to point to alb
resource "aws_route53_record" "a_record" {
  zone_id = var.r53_zone_id
  name    = var.r53_record_name
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_acm_certificate_validation.cert_validation]
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.my_certificate.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name   = "alb-target-group"
  vpc_id = aws_vpc.land_tasker_vpc.id

  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"

  health_check {
    path     = "/api/v1/health"

    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

#ecr
resource "aws_ecr_repository" "job_post_api_1" {
  name = "job-post-api-1"

  image_tag_mutability = "MUTABLE"
}

#ecs
resource "aws_security_group" "land_tasker_ecs_sg" {
  name        = "LandTaskerECSSG"
  description = "Security group for ECS Fargate"
  vpc_id      = aws_vpc.land_tasker_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = var.protocol
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_blocks_anywhere]
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "land-tasker-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = [var.ecs_launch_type]
  cpu                              = var.task_cpu
  memory                           = var.task_memory
  execution_role_arn = var.execution_role_arn
  task_role_arn = var.execution_role_arn

  container_definitions = jsonencode([{
      name  = var.container_name
      image = var.image

      portMappings = [
        {
          name          = "landtaskerecr-5000-tcp"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = var.protocol
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = var.enable_awslogs
          "awslogs-group"         = "/ecs/${var.container_name}"
          "awslogs-region"        = var.region  
          "awslogs-stream-prefix" = "ecs"
        }
      }
  }])

  runtime_platform {
    operating_system_family = var.task_operating_system_family
    cpu_architecture        = var.task_cpu_architecture
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "land-tasker-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = var.ecs_launch_type
  desired_count          = var.desired_count
  enable_execute_command = var.enable_execute_command

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    subnets = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.land_tasker_ecs_sg.id]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "land-tasker-ecs-cluster"

  setting {
      name  = "containerInsights"
      value = var.enable_containerInsights
    }
}

resource "aws_cloudwatch_log_group" "cw_log" {
  name = "/ecs/${var.container_name}"
}

