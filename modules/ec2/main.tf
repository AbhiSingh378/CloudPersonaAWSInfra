# First create the security groups
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

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    Name = "${var.project_name}-app-sg"
  }
}

# Then create the EC2 instance
resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    # Backup existing .env file if it exists
    if [ -f /opt/csye6225/webapp/.env ]; then
      cp /opt/csye6225/webapp/.env /opt/csye6225/webapp/.env.backup
    fi
    
    # Create new .env file with database configuration
    cat <<EOT > /opt/csye6225/webapp/.env
    FLASK_APP=webapp.py
    FLASK_ENV=development
    HOSTNAME=0.0.0.0
    DB_NAME=${var.db_name}
    DB_USER=${var.db_username}
    DB_PASSWORD=${var.db_password}
    DB_HOST=${var.db_endpoint}
    SQLALCHEMY_DATABASE_URI=mysql+pymysql://${var.db_username}:${var.db_password}@${var.db_endpoint}/${var.db_name}
    AWS_BUCKET_NAME=${var.s3_bucket_name}
    AWS_REGION=${var.aws_region}
    EOT

    # Ensure the logs directory exists
    mkdir -p /opt/csye6225/webapp/logs

    # Ensure correct permissions for the log file
    sudo touch /opt/csye6225/webapp/logs/webapp.log
    sudo chmod 664 /opt/csye6225/webapp/logs/webapp.log
    sudo chown ubuntu:ubuntu /opt/csye6225/webapp/logs/webapp.log

    # Configure and start CloudWatch agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/cloudwatch-config.json \
    -s

    # Enable and start the web application service
    sudo systemctl enable webapp.service
    sudo systemctl daemon-reload
    sudo systemctl restart webapp.service
EOF
  )

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-app-server"
  }
}

# Add this resource after your EC2 instance
resource "aws_route53_record" "app_record" {
  zone_id = var.route53_zone_id
  name    = "${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.app_server.public_ip]
}
