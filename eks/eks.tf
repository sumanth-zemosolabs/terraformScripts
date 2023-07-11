data "aws_iam_policy_document" "eks-trusty" {
  statement {
    principals {
      type = "Service"
      identifiers = [ "eks.amazonaws.com" ]
    }
    actions = [ "sts:AssumeRole" ]
  }
}

data "aws_iam_policy_document" "ec2-trusty" {
  statement {
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
    actions = [ "sts:AssumeRole" ]
  }
}

resource "aws_iam_role" "eks-node-role" {
  name = "${var.cluster_name}-eks-node-role"
  tags = local.tags
  inline_policy {
    name = "route53"
    policy = jsonencode(
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
              "arn:aws:route53:::hostedzone/*"
            ]
          },
          {
            "Effect": "Allow",
            "Action": [
              "route53:ListHostedZones",
              "route53:ListResourceRecordSets"
            ],
            "Resource": [
              "*"
            ]
          }
        ]
      }
    )
  }
  assume_role_policy = data.aws_iam_policy_document.ec2-trusty.json
  managed_policy_arns = [ "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" ]
}

resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.cluster_name}-eks-cluster-role"
  tags = local.tags
  assume_role_policy = data.aws_iam_policy_document.eks-trusty.json
  managed_policy_arns = [ "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSServicePolicy" ]
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.vpc.id ]
  }
}

data "aws_subnet" "subnet" {
  id = data.aws_subnets.subnets.ids[count.index]
  count = length(data.aws_subnets.subnets.ids)
}

resource "aws_eks_cluster" "my-cluster" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-role.arn
  version = var.eks_version
  # to use private subnets also add those subnets here in this subnet_ids
  vpc_config {
    subnet_ids = concat(local.public_subnets, local.private_subnets)
  }
  tags = local.tags
}

# resource "aws_eks_node_group" "public-node-group" {
#   cluster_name = aws_eks_cluster.my-cluster.name
#   node_role_arn = aws_iam_role.eks-node-role.arn
#   scaling_config {
#     desired_size = 1
#     max_size = 4
#     min_size = 1
#   }
#   labels = {
#     "group" = "public"
#   }
#   subnet_ids = local.public_subnets
#   ami_type = "AL2_x86_64"
#   capacity_type = "ON_DEMAND"
#   tags = local.tags
#   node_group_name = "public-ng"
# }

resource "aws_eks_node_group" "private-node-group" {
  cluster_name = aws_eks_cluster.my-cluster.name
  node_role_arn = aws_iam_role.eks-node-role.arn
  scaling_config {
    desired_size = 2
    max_size = 4
    min_size = 1
  }
  labels = {
    "group" = "private"
  }
  subnet_ids = local.private_subnets
  ami_type = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  tags = local.tags
  node_group_name = "private-ng"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.my-cluster.name
  addon_name = "vpc-cni"
  addon_version = "v1.10.4-eksbuild.1"
  depends_on = [ aws_eks_node_group.private-node-group ]
}

resource "aws_eks_addon" "coreDns" {
  cluster_name = aws_eks_cluster.my-cluster.name
  addon_name = "coredns"
  addon_version = "v1.8.7-eksbuild.2"
  depends_on = [ aws_eks_node_group.private-node-group ]
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.my-cluster.name
  addon_name = "kube-proxy"
  addon_version = "v1.23.7-eksbuild.1"
  depends_on = [ aws_eks_node_group.private-node-group ]
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name = aws_eks_cluster.my-cluster.name
  addon_name = "aws-ebs-csi-driver"
  addon_version = "v1.16.0-eksbuild.1"
  depends_on = [ aws_eks_node_group.private-node-group ]
}
