data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Web Tier ASG
resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.project_name}-web-lt"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_tier_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo amazon-linux-extras install nginx1 -y
              aws s3 cp s3://${aws_s3_bucket.app_code.id}/web-tier-build.zip /tmp/web-tier-build.zip
              unzip /tmp/web-tier-build.zip -d /home/ec2-user/web-tier/build
              # Move nginx.conf and restart
              aws s3 cp s3://${aws_s3_bucket.app_code.id}/nginx.conf /etc/nginx/nginx.conf
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
  )
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.project_name}-web-asg"
  vpc_zone_identifier = aws_subnet.private_app[*].id
  target_group_arns    = [aws_lb_target_group.web_tg.arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
}

# App Tier ASG
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-app-lt"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_tier_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
              sudo yum install -y nodejs
              mkdir -p /home/ec2-user/app-tier
              aws s3 cp s3://${aws_s3_bucket.app_code.id}/app-tier.zip /tmp/app-tier.zip
              unzip /tmp/app-tier.zip -d /home/ec2-user/app-tier
              cd /home/ec2-user/app-tier
              npm install
              node index.js
              EOF
  )
}

resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.project_name}-app-asg"
  vpc_zone_identifier = aws_subnet.private_app[*].id
  target_group_arns    = [aws_lb_target_group.app_tg.arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}
