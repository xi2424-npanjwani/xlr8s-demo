
terraform {
  required_version = ">= 0.13.1"
}

module "my_eks" {
  source = "../../../../_terraform_modules/xebia/terraform-aws-xebia-eks@v0.11.0"
	
  cluster_name = var.cluster_name
  existing_vpc = var.existing_vpc
  required_labels = var.required_labels
}
