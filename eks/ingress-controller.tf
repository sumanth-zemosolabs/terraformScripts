resource "kubectl_manifest" "ingress-controller-manifest" {
  yaml_body = data.kubectl_file_documents.ingress-controller.documents[count.index]
  count = length(data.kubectl_file_documents.ingress-controller.documents)
  depends_on = [
    aws_eks_node_group.private-node-group,
    # aws_eks_node_group.public-node-group
  ]
}

data "kubectl_file_documents" "ingress-controller" {
  content = templatefile("ingress-controller.yaml", {hostedZoneName = data.aws_route53_zone.hostedzone.name, hostedZoneArn = data.aws_acm_certificate.acm.arn})
}

data "aws_eks_cluster_auth" "token" {
  name = aws_eks_cluster.my-cluster.name
}

data "aws_route53_zone" "hostedzone" {
  name = var.hostedzone
  private_zone = false
}

data "aws_acm_certificate" "acm" {
  domain = var.hostedzone
}