resource "aws_iam_role" "eks_oidc_role" {
  name = "eks-service-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Federated = var.eks_oidc_provider_arn },
      Action    = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.eks_oidc_issuer_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name = "eks-service-account-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks-sa-policy" {
  role       = aws_iam_role.eks_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "rds-access-policy" {
  role       = aws_iam_role.eks_oidc_role.name
  policy_arn = "arn:aws:iam::533267406282:policy/rds-access-policy"
}