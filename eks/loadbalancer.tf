resource "aws_autoscaling_attachment" "ast" {
  autoscaling_group_name = aws_eks_node_group.private-node-group.resources.0.autoscaling_groups.0.name
  for_each = {for target in var.asg-ports: target.name => target}
  lb_target_group_arn = aws_lb_target_group.ast-tg[each.key].arn
}

resource "aws_lb_target_group" "ast-tg" {
  name = "${var.cluster_name}-${each.key}"
  for_each = {for target in var.asg-ports: target.name => target}
  port = each.value.nodePort
  protocol = "TCP"
  target_type = "instance"
  vpc_id = data.aws_vpc.vpc.id
}

resource "aws_lb_listener" "ast-listener" {
  load_balancer_arn = data.aws_alb.ingress-controller-loadbalancer.arn
  for_each = {for target in var.asg-ports: target.name => target}
  port = each.value.port
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ast-tg[each.key].arn
  }
  tags = local.tags
}

resource "aws_security_group_rule" "asg-tg-ports" {
  security_group_id = aws_eks_cluster.my-cluster.vpc_config.0.cluster_security_group_id
  for_each = {for target in var.asg-ports: target.name => target}
  type = "ingress"
  from_port = each.value.nodePort
  to_port = each.value.nodePort
  protocol = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
}