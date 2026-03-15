# External Load Balancer for Web Tier
resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-web-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Internal Load Balancer for App Tier
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb_sg.id]
  subnets            = aws_subnet.private_app[*].id

  tags = {
    Name = "${var.project_name}-app-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-app-tg"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
