data "kubernetes_service" "ingress-controller-service" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [ kubectl_manifest.ingress-controller-manifest ]
}
resource "kubernetes_namespace_v1" "ingress-nginx" {
  metadata {
    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"
      "app.kubernetes.io/name" = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
  depends_on = [ 
    aws_eks_node_group.private-node-group,
    aws_eks_addon.aws-ebs-csi-driver,
    aws_eks_addon.coreDns,
    aws_eks_addon.kube-proxy,
    aws_eks_addon.vpc-cni
    ]
}
resource "aws_route53_record" "records" {
  count = length(var.project_domains)
  zone_id = data.aws_route53_zone.hostedzone.zone_id
  name = "${var.project_domains[count.index]}.${var.hostedzone}"
  type = "A"
  # records = [ data.kubernetes_service.ingress-controller-service.status.0.load_balancer.0.ingress.0.hostname ]
  depends_on = [ kubectl_manifest.ingress-controller-manifest ]
  alias {
    name = data.aws_alb.ingress-controller-loadbalancer.dns_name
    zone_id = data.aws_alb.ingress-controller-loadbalancer.zone_id
    evaluate_target_health = true
  }
}

data "aws_alb" "ingress-controller-loadbalancer" {
  name = local.loadbalancer_dns_name
}

