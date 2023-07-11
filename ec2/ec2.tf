resource "aws_instance" "ec2" {
  ami = "ami-007855ac798b5175e"
  for_each = {
    for instance in var.ec2: instance.tier => instance
  }
  key_name = var.ec2-key
  instance_type = each.value.instance_type
  subnet_id = local.public_subnets[0]
  root_block_device {
    volume_size = each.value.volume_size
  }
  lifecycle {
    ignore_changes = [
      root_block_device["volume_size"],
      subnet_id,
      ami,
      security_groups
    ]
  }
  security_groups = [ aws_security_group.asg.id ]
  tags = merge({Name: "${var.project}-${each.key}"},local.tags,{tier: "${each.key}"})
}

resource "aws_security_group" "asg" {
  name = "${var.project}-asg"
  tags = local.tags
  vpc_id = data.aws_vpc.vpc.id
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = [ "0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "asg-rules" {
  for_each = toset(var.project_ports)
  from_port = each.value
  to_port = each.value
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
  security_group_id = aws_security_group.asg.id
}

# data "aws_ami" "ubuntu" {
#   filter {
#     name = "root-device-type"
#     values = ["ebs"]
#   }
#   filter {
#     name = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["amazon"]
#   most_recent = true
#   filter {
#     name = "architecture"
#     values = [ "x86_64" ]
#   }  
#   name_regex = "ubuntu/images/.*22.04.*"
# }