module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-1a", "us-west-1c"]
  vpc_name           = "my-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-7-django-app"
  scan_on_push = true
}

module "eks" {
  source        = "./modules/eks"
  cluster_name  = "eks-cluster-demo"
  subnet_ids    = module.vpc.public_subnets
  instance_type = "t4g.small"
  desired_size  = 2
  max_size      = 3
  min_size      = 1
}

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  github_username   = var.github_username
  github_pat        = var.github_pat
  github_repo_url   = var.github_repo_url

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
}

module "argo_cd" {
  source            = "./modules/argo_cd"
  app_repo_url      = var.app_repo_url
  app_repo_username = var.app_repo_username
  app_repo_password = var.app_repo_password

  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }

  depends_on = [module.jenkins]
}
