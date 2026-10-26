module "networking" {
  source      = "git::https://github.com/Eyitoyosi/cob.git//modules/networking?ref=v0.1.0"
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "ecs_cluster" {
  source      = "git::https://github.com/Eyitoyosi/cob.git//modules/compute-ecs-cluster?ref=v0.1.0"
  environment = var.environment
}
