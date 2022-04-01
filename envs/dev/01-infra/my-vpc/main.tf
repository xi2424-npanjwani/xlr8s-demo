
terraform {
  required_version = ">= 0.13.1"
}

module "my_vpc" {
  source = "../../../../_terraform_modules/xebia/terraform-aws-xebia-vpc@v0.10.0"
	
  cidr = var.cidr
  name = var.name
}
