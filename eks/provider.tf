provider "aws" {
  #profile = "sso"
  region = "us-east-1"
}

provider "kubectl" {
  host = aws_eks_cluster.my-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.my-cluster.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.token.token
}

provider "kubernetes" {
  host = aws_eks_cluster.my-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.my-cluster.certificate_authority[0].data)
  # token = data.aws_eks_cluster_auth.token.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.my-cluster.name]
    command     = "aws"
  }
}