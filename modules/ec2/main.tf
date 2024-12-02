# Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
#  ingress {
#    description = "Allow HTTP from anywhere (IPv6)"
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    ipv6_cidr_blocks = ["::/0"]
#  }

  ingress {
    description = "Allow HTTPS from anywhere (IPv6)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Application Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for web applications"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# Launch Template
resource "aws_launch_template" "app_template" {
  name          = "csye6225_asg"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = true
      kms_key_id  = var.ec2_kms_key_arn
      volume_size = 8
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    # Update and install AWS CLI and jq
    apt-get update && apt-get install -y awscli jq

    # Function to check AWS credentials
    check_aws_credentials() {
      for i in {1..150}; do
        if aws sts get-caller-identity >/dev/null 2>&1; then
          echo "AWS credentials available"
          return 0
        fi
        echo "Waiting for AWS credentials... attempt $i"
        sleep 10
      done
      return 1
    }

    # Function to fetch secrets
    fetch_secrets() {
      for i in {1..60}; do
        echo "Attempting to fetch secrets... attempt $i"
        
        # Fetch database credentials
        DB_SECRETS=$(aws secretsmanager get-secret-value --secret-id ${var.db_secret_arn} --region ${var.aws_region} --query SecretString --output text)
        if [ $? -eq 0 ]; then
          DB_USERNAME=$(echo $DB_SECRETS | jq -r .username)
          DB_PASSWORD=$(echo $DB_SECRETS | jq -r .password)
          DB_HOST_FULL=$(echo $DB_SECRETS | jq -r .host)
          DB_HOST=$(echo $DB_HOST_FULL | cut -d':' -f1)
          
          # Fetch email service credentials
          EMAIL_SECRETS=$(aws secretsmanager get-secret-value --secret-id ${var.email_secret_arn} --region ${var.aws_region} --query SecretString --output text)
          if [ $? -eq 0 ]; then
            # Verify we got valid values
            if [ "$DB_HOST" != "null" ] && [ "$DB_HOST" != "" ] && [ "$DB_HOST" != "localhost" ]; then
              echo "Successfully retrieved DB credentials with host: $DB_HOST"
              return 0
            else
              echo "Invalid DB_HOST value: $DB_HOST"
            fi
          fi
        fi
        
        sleep 10
      done
      return 1
    }

    # Wait for AWS credentials
    if ! check_aws_credentials; then
      echo "Failed to obtain AWS credentials"
      exit 1
    fi

    # Fetch secrets with retry
    if ! fetch_secrets; then
      echo "Failed to fetch secrets"
      exit 1
    fi


    if [ -f /opt/csye6225/webapp/.env ]; then
      cp /opt/csye6225/webapp/.env /opt/csye6225/webapp/.env.backup
    fi
    

    # Create .env file only if we have all required variables
    if [ -n "$DB_USERNAME" ] && [ -n "$DB_PASSWORD" ] && [ -n "$DB_HOST" ]; then
      cat <<EOT > /opt/csye6225/webapp/.env
    FLASK_APP=webapp.py
    FLASK_ENV=development
    HOSTNAME=0.0.0.0
    DB_NAME=${var.db_name}
    DB_USER=$DB_USERNAME
    DB_PASSWORD=$DB_PASSWORD
    DB_HOST=$DB_HOST
    SQLALCHEMY_DATABASE_URI=mysql+pymysql://$DB_USERNAME:$DB_PASSWORD@$DB_HOST/${var.db_name}
    AWS_BUCKET_NAME=${var.s3_bucket_name}
    AWS_REGION=${var.aws_region}
    SNS_TOPIC_ARN=${var.sns_topic_arn}
    $(echo $EMAIL_SECRETS | jq -r 'to_entries | .[] | .key + "=" + .value')
    EOT
    else
      echo "Missing required credentials"
      exit 1
    fi


    mkdir -p /opt/csye6225/webapp/logs
    sudo touch /opt/csye6225/webapp/logs/webapp.log
    sudo chmod 664 /opt/csye6225/webapp/logs/webapp.log
    sudo chown ubuntu:ubuntu /opt/csye6225/webapp/logs/webapp.log

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/cloudwatch-config.json \
    -s

    sudo systemctl enable webapp.service
    sudo systemctl daemon-reload
    sudo systemctl restart webapp.service
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app-server"
    }
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project_name}-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    timeout             = 5
    path                = "/healthz"
    port                = "5000"
    unhealthy_threshold = 5
  }
}

# ALB Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_listener" "app_http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
      }
    }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.project_name}-asg"
  desired_capacity          = 3
  max_size                  = 5
  min_size                  = 3
  wait_for_capacity_timeout = "0"
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  vpc_zone_identifier       = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-cpu-scale-up-step"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Scale Up Alarm
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "${var.project_name}-cpu-scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 9

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "This metric monitors EC2 CPU utilization for scale-out"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-cpu-scale-down-step"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Scale Down Alarm
resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "${var.project_name}-cpu-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 7.5

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "This metric monitors EC2 CPU utilization for scale-in"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}

# Route53 Record
resource "aws_route53_record" "app_record" {
  zone_id = var.route53_zone_id
  name    = "${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}
