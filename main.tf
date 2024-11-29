variable "name" {
  description ="name of application"
  type = string
  default = "yap"
}

data "aws_vpc" "default" {
  default = true
} 

data "aws_subnets" "public" {
  filter{
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name = "tag:Name"
    values = ["public-*"]
  }
}

locals {
  department = "marketing"
}

resource "aws_instance" "public" {
    ami = "ami-04c913012f8977029"
    instance_type = "t2.micro"
    subnet_id = data.aws_subnets.public.ids[1] #Public Subnet ID, e.g. subnet-xxxxxxxxxxx
    associate_public_ip_address = true
    #key_name = "yap-231124" #Change to your keyname, e.g. jazeel-key-pair
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]

    tags = {
        Name = "${var.name}-ec2"
        Department = local.department
        }
}

resource "aws_security_group" "allow_ssh" {
    name_prefix = "${var.name}-sg" #Security group name, e.g. jazeel-terraform-security-group
    description = "Allow SSH inbound"
    vpc_id = data.aws_vpc.default.id #VPC ID (Same VPC as your EC2 subnet above), E.g. vpc-xxxxxxx
    lifecycle {
      create_before_destroy = true
    }
    tags = {
        Department = local.department
        }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
    security_group_id = aws_security_group.allow_ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
}

output "public_ip" {
  value = aws_instance.public.public_ip
}

output "public_dns" {
  value = aws_instance.public.public_dns
}

output "public_subnet_ids" {
  value = data.aws_subnets.public.ids
}