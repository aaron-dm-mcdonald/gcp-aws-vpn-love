module "aws_network" {
  source                = "./modules/aws_network"
  region                = var.aws_config.region
  vpc_cidr              = var.aws_config.vpc_cidr  
  public_subnet_a_cidr  = var.aws_config.public_subnet_a_cidr
  private_subnet_a_cidr = var.aws_config.private_subnet_a_cidr
}