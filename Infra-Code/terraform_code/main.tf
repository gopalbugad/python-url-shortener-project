module "iam" {
  source = "./module/iam"
}

module "vpc" {
  source = "./module/vpc"
}

module "eks" {
  source           = "./module/eks"
  eks_cluster_name = "k8s-cluster"
  node_group_name  = "k8s-cluster-ng"
  eks_cluster_role = module.iam.eks_cluster_role_arn
  eks_node_role    = module.iam.eks_node_role_arn
  subnet_ids       = module.vpc.eks_public_subnet_ids
  desired_size     = 1
  min_size         = 1
  max_size         = 1
  disk_size        = 20
  vpc_id           = module.vpc.eks_vpc_id
  rds-sg           = module.rds.rds-sg-id
}

module "iam_post" {
  source                = "./module/iam_post"
  eks_oidc_provider_arn = module.eks.eks_oidc_provider_arn
  eks_oidc_issuer_url   = module.eks.eks_oidc_issuer_url

  depends_on = [module.eks]
}

module "rds" {
  source                  = "./module/rds"
  allocated_storage       = 20
  identifier              = "postgresql-db"
  instance_class          = "db.t3.micro"
  engine_version          = "17.2"
  publicly_accessible     = true
  backup_retention_period = 1
  deletion_protection     = false
  subnet_ids              = module.vpc.eks_public_subnet_ids
  vpc_id                  = module.vpc.eks_vpc_id
  eks-sg-id               = module.eks.eks_sg_id

  depends_on = [module.vpc]
}