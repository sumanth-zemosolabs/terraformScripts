locals {
  tags = {
    createdBy = "Sumanth Pola"
    email = "sumanth.pola@zemosolabs.com"
  }
  loadbalancer_dns = data.kubernetes_service.ingress-controller-service.status.0.load_balancer.0.ingress.0.hostname
  loadbalancer_dns_name = split("-", split(".", "${local.loadbalancer_dns}")[0])[0]
}
variable "cluster_name" {
  description = "Name of the cluster"
  type = string
  default = "sumanth-cluster"
}
variable "vpc_id" {
  description = "aws vpc id"
  type = string
  default = "vpc-009470e55cc89e05e"
}
variable "eks_version" {
  description = "eks kubernetes version"
  type = number
  default = 1.23
}

locals {
  public_subnets = [for subnet in data.aws_subnet.subnet: subnet.id if subnet.map_public_ip_on_launch]
  private_subnets = [for subnet in data.aws_subnet.subnet: subnet.id if !subnet.map_public_ip_on_launch]
}

variable "hostedzone" {
  description = "provide the hostedzone url"
  type = string
  default = "bootcamp64.tk"
}

variable "project_domains" {
  description = "list of all subdomains required for this bootcamp"
  type = list(string)
}