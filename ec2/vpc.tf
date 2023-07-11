data "aws_vpc" "vpc" {
  id = var.vpc
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id = each.key
}