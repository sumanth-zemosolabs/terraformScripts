project = "bc84"
ec2 = [{
    tier = "frontend"
    instance_type = "t3.medium"
    volume_size = 30
  },
  {
    tier = "backend"
    instance_type = "t3.medium"
    volume_size = 30
  }]
project_ports = ["22", "8080", "80", "443", "3306", "8761", "9000", "9001"]
vpc = "vpc-0b07c6d5f7478d36e"
ec2-key = "sumanth-pola-us-east-1"
project_domain = "bootcamp64.tk"
subdomains = [ "bc84mockserver", "bc84fe", "bc84be" ]