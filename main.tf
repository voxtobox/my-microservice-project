module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr_block      = "10.0.0.0/16"
  public_subnets      = ["10.0.1.0/24", "10.0.3.0/24"]
  private_subnets     = ["10.0.4.0/24", "10.0.6.0/24"]
  availability_zones  = ["us-west-1a", "us-west-1c"]
  vpc_name            = "my-vpc"
}

module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "lesson-7-django-app"
  scan_on_push = true
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "eks-cluster-demo"
  subnet_ids      = module.vpc.public_subnets
  instance_type   = "t4g.small"
  desired_size    = 2
  max_size        = 3
  min_size        = 1
}
