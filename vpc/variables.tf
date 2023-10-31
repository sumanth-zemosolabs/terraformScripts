locals {
  tags = {
    createdBy : "Sumanth Pola",
    email : "sumanth.pola@zemosolabs.com"
  }
}

variable "subnet" {
  default = [
    {
      cidr_block        = "10.0.0.0/22"
      availability_zone = "us-east-1a"
      enable_public_ip  = true
      Name              = "public-subnet-a"
    },
    {
      cidr_block        = "10.0.4.0/22"
      availability_zone = "us-east-1b"
      enable_public_ip  = true
      Name              = "public-subnet-b"
    },
    {
      cidr_block        = "10.0.8.0/22"
      availability_zone = "us-east-1c"
      enable_public_ip  = false
      Name              = "private-subnet-a"
    },
    {
      cidr_block        = "10.0.12.0/22"
      availability_zone = "us-east-1a"
      enable_public_ip  = false
      Name              = "private-subnet-b"
    },
    {
      cidr_block        = "10.0.16.0/22"
      availability_zone = "us-east-1c"
      enable_public_ip  = true
      Name              = "public-subnet-c"
    },
    {
      cidr_block        = "10.0.20.0/22"
      availability_zone = "us-east-1b"
      enable_public_ip  = false
      Name              = "private-subnet-c"
  }]
  type = list(object({
    cidr_block        = string
    availability_zone = string
    enable_public_ip  = bool
    Name              = string
  }))
}

locals {
  public_subnets  = [for name, value in aws_subnet.subnets : value.id if value.map_public_ip_on_launch]
  private_subnets = [for name, value in aws_subnet.subnets : value.id if !value.map_public_ip_on_launch]
}
