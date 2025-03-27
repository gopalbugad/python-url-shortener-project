resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = var.eks_cluster_role

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  access_config {
    authentication_mode = "API"
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = var.eks_node_role
  subnet_ids      = var.subnet_ids
  disk_size       = var.disk_size
  instance_types  = ["t2.medium"]

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_entry" "name" {
  cluster_name      = var.eks_cluster_name
  principal_arn     = "arn:aws:iam::533267406282:root"
  type              = "STANDARD"

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

resource "aws_eks_access_policy_association" "access_policy" {
  cluster_name  = var.eks_cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::533267406282:root"

  access_scope {
    type       = "cluster"
  }

  depends_on = [ aws_eks_cluster.eks_cluster ]
}

data "aws_security_group" "eks_default_sg" {
  id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_security_group_rule" "rule-1" {
  security_group_id = data.aws_security_group.eks_default_sg.id
  description       = "This rule will allow to serve frontend application."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 30001
  to_port           = 30001
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rule-2" {
  security_group_id = data.aws_security_group.eks_default_sg.id
  description       = "This rule will allow to serve backend application."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 30002
  to_port           = 30002
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rule-4" {
  security_group_id = data.aws_security_group.eks_default_sg.id
  description       = "This rule will allow to serve backend application."
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 30003
  to_port           = 30003
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rule-3" {
  security_group_id        = data.aws_security_group.eks_default_sg.id
  description              = "This rule will allow to communicate with RDS DB instance."
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = var.rds-sg
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "eks_oidc_issuer_url" {
  description = "OIDC Issuer URL for EKS"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "eks_oidc_provider_arn" {
  description = "IAM OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "eks_sg_id" {
  value = data.aws_security_group.eks_default_sg.id
}