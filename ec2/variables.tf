variable "vpc" {
  type = string
  description = "vpc id"
  default = "vpc-0b07c6d5f7478d36e"
}

locals {
  public_subnets = [for subnet in data.aws_subnet.subnet: subnet.id if subnet.map_public_ip_on_launch]
  private_subnets = [for subnet in data.aws_subnet.subnet: subnet.id if !subnet.map_public_ip_on_launch]
  tags = {
    createdBy = "Sumanth Pola"
    email = "sumanth.pola@zemosolabs.com"
  }
}

variable "project" {
  default = "callicoder-v2"
}

variable "ec2-key" {
  type = string
  default = "sumanth-pola-us-east-1"
}

variable "ec2" {
  default = [{
    tier = "frontend"
    instance_type = "t3.medium"
    volume_size = 30
  },
  {
    tier = "backend"
    instance_type = "t3.medium"
    volume_size = 30
  }]
  type = list(object({
    tier = string
    instance_type = string
    volume_size = number
  }))
}

variable "project_ports" {
  type = list(string)
  default = ["22","8080","80","443","3306"]
  description = "ports used in the project"
}

variable "project_domain" {
  type = string
  default = "bootcamp64.tk"
  description = "domain used for project"
}

variable "subdomains" {
  type = list(string)
  description = "list of all subdomains used in project domain for this project"
}