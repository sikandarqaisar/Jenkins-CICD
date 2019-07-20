provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "./modules/vpc"
  namePrefix = "${var.namePrefix}"
  awsRegion ="${var.awsRegion}"
}

module "ec2" {
  source = "./modules/ec2"
  sgec2 = "${module.vpc.sgec2}"
  subnetId = "${module.vpc.subnetId}"
  namePrefix = "${var.namePrefix}"
}

