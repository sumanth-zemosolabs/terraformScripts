# output "ec2-trusty-json" {
#   description = "json document of the ec2-trusty for iam role"
#   value = data.aws_iam_policy_document.ec2-trusty.json
# }

# output "eks-trusty-json" {
#   description = "json document of the eks-trusty for iam role"
#   value = data.aws_iam_policy_document.eks-trusty.json
# }

# output "subnets" {
#   description = "subnets available in the default vpc"
#   value = data.aws_subnets.subnets
# }


# output "eks_ca" {
#   value = aws_eks_cluster.my-cluster.certificate_authority
# }

output "ingress-nginx-controller-service" {
  value = data.kubernetes_service.ingress-controller-service.status.0.load_balancer.0.ingress.0.hostname
}

output "test" {
  value = local.loadbalancer_dns_name
}