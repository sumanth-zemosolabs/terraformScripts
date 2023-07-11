output "public_subnet" {
  value = local.public_subnets
}

output "private_subnets" {
  value = local.private_subnets
}

output "ec2" {
  value = aws_instance.ec2["frontend"].public_ip
}

# output "ami" {
#   value = data.aws_ami.ubuntu
# }