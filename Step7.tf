## Terraform config file to automate EC2 instance provisioning using System Manager and CloudFormation ##

# Define your provider block with the appropriate AWS credentials
provider "aws" {
  region = "us-east-1" # Update with your desired region
}

# Prompt the user for input variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  type        = string
}

variable "key_pair" {
  description = "Key pair name"
  type        = string
}

variable "security_group" {
  description = "Security group ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

# Create a Systems Manager document to run an EC2 instance
resource "aws_ssm_document" "ec2_document" {
  name = "create-ec2-instance"

  content = <<EOF
    {
      "schemaVersion": "2.2",
      "description": "Create an EC2 instance",
      "parameters": {
        "InstanceType": {
          "type": "String",
          "description": "EC2 instance type"
        },
        "ImageId": {
          "type": "String",
          "description": "Amazon Machine Image ID"
        },
        "KeyName": {
          "type": "String",
          "description": "Key pair name"
        },
        "SecurityGroupId": {
          "type": "String",
          "description": "Security group ID"
        },
        "SubnetId": {
          "type": "String",
          "description": "Subnet ID"
        }
      },
      "mainSteps": [
        {
          "action": "aws:runInstances",
          "name": "runInstances",
          "inputs": {
            "ImageId": "{{ ImageId }}",
            "InstanceType": "{{ InstanceType }}",
            "KeyName": "{{ KeyName }}",
            "SecurityGroupIds": ["{{ SecurityGroupId }}"],
            "SubnetId": "{{ SubnetId }}",
            "MinCount": 1,
            "MaxCount": 1
          }
        }
      ]
    }
  EOF
}

# Create an SSM association to run the EC2 instance document
resource "aws_ssm_association" "ec2_association" {
  name = "run-ec2-instance"
  document_version = "$LATEST"
  parameters = {
    "InstanceType"    = var.instance_type
    "ImageId"         = var.ami_id
    "KeyName"         = var.key_pair
    "SecurityGroupId" = var.security_group
    "SubnetId"        = var.subnet_id
  }
}

# Create a CloudFormation stack to provision the EC2 instance
resource "aws_cloudformation_stack" "ec2_stack" {
  name           = "ec2-instance-stack"
  template_body = <<EOF
    AWSTemplateFormatVersion: "2010-09-09"
    Resources:
      EC2Instance:
        Type: "AWS::EC2::Instance"
        Properties:
          InstanceType: "${var.instance_type}"
          ImageId: "${var.ami_id}"
          KeyName: "${var.key_pair}"
          SecurityGroupIds:
            - "${var.security_group}"
          SubnetId: "${var.subnet_id}"
          UserData: !Base64 |
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl enable httpd
            systemctl start httpd
            iptables -A INPUT -p tcp --dport 80 -j ACCEPT
            service iptables save
            EOF
}

# Output the public IP address of the EC2 instance
output "public_ip" {
  value = aws_cloudformation_stack.ec2_stack.outputs["EC2InstancePublicIp"]
}

# Define your provider block with the appropriate AWS credentials
provider "aws" {
  region = "us-east-1" # Update with your desired region
}

# Prompt the user for input variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  type        = string
}

variable "key_pair" {
  description = "Key pair name"
  type        = string
}

variable "security_group" {
  description = "Security group ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

# Create a Systems Manager document to run an EC2 instance
resource "aws_ssm_document" "ec2_document" {
  name = "create-ec2-instance"

  content = <<EOF
    {
      "schemaVersion": "2.2",
      "description": "Create an EC2 instance",
      "parameters": {
        "InstanceType": {
          "type": "String",
          "description": "EC2 instance type"
        },
        "ImageId": {
          "type": "String",
          "description": "Amazon Machine Image ID"
        },
        "KeyName": {
          "type": "String",
          "description": "Key pair name"
        },
        "SecurityGroupId": {
          "type": "String",
          "description": "Security group ID"
        },
        "SubnetId": {
          "type": "String",
          "description": "Subnet ID"
        }
      },
      "mainSteps": [
        {
          "action": "aws:runInstances",
          "name": "runInstances",
          "inputs": {
            "ImageId": "{{ ImageId }}",
            "InstanceType": "{{ InstanceType }}",
            "KeyName": "{{ KeyName }}",
            "SecurityGroupIds": ["{{ SecurityGroupId }}"],
            "SubnetId": "{{ SubnetId }}",
            "MinCount": 1,
            "MaxCount": 1,
            "UserData": "{{ UserData }}"
          }
        }
      ]
    }
  EOF
}

# Create an SSM association to run the EC2 instance document
resource "aws_ssm_association" "ec2_association" {
  name             = "run-ec2-instance"
  document_version = "$LATEST"
  parameters = {
    "InstanceType"    = var.instance_type
    "ImageId"         = var.ami_id
    "KeyName"         = var.key_pair
    "SecurityGroupId" = var.security_group
    "SubnetId"        = var.subnet_id
    "UserData"        = base64encode(data.template_file.user_data.rendered)
  }
}

# Create a CloudFormation stack to provision the EC2 instance
resource "aws_cloudformation_stack" "ec2_stack" {
  name           = "ec2-instance-stack"
  template_body = <<EOF
    AWSTemplateFormatVersion: "2010-09-09"
    Resources:
      EC2Instance:
        Type: "AWS::EC2::Instance"
        Properties:
          InstanceType: "${var.instance_type}"
          ImageId: "${var.ami_id}"
          KeyName: "${var.key_pair}"
          SecurityGroupIds:
            - "${var.security_group}"
          SubnetId: "${var.subnet_id}"
          UserData: !Base64 |
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl enable httpd
            systemctl start httpd
            iptables -A INPUT -p tcp --dport 80 -j ACCEPT
            service iptables save
            EOF
}

# Create a security group for the ELB
resource "aws_security_group" "elb_security_group" {
  name        = "elb-security-group"
  description = "Security group for the ELB"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate a self-signed SSL certificate for test purposes
resource "tls_self_signed_cert" "self_signed_cert" {
  key_algorithm   = "RSA"
  private_key_pem = <<EOF
    -----BEGIN RSA PRIVATE KEY-----
    ##enter valid certificate here##
    -----END RSA PRIVATE KEY-----
  EOF
  certificate_pem = <<EOF
    -----BEGIN CERTIFICATE-----
    ##enter valid certificate here##
    -----END CERTIFICATE-----
  EOF
}

# Create an ELB to forward traffic to the EC2 instance
resource "aws_lb" "elb" {
  name               = "DevOps_LB"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.subnet_id]
  security_groups    = [aws_security_group.elb_security_group.id]

  enable_deletion_protection = false

  listener {
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    ssl_certificate_id   = tls_self_signed_cert.self_signed_cert.cert_pem_path
  }

  tags = {
    Owner = "Dario"
    Environment = "Dev"
    Name = "DevOps_LB"
  }
}

# Create a Route 53 DNS record for the ELB
resource "aws_route53_record" "elb_dns" {
  zone_id = var.route53_zone_id
  name    = "interviewlab.com"
  type    = "A"

  alias {
    name                   = aws_lb.elb.dns_name
    zone_id                = aws_lb.elb.zone_id
    evaluate_target_health = false
  }
}

# Output the DNS name of the ELB and the Route 53 DNS record
output "elb_dns_name" {
  value = aws_lb.elb.dns_name
}

output "route53_dns_name" {
  value = aws_route53_record.elb_dns.name
}

