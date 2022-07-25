
terraform {
  backend "s3" {	
    bucket = "xlr8s-artifacts"
    encrypt = "false"
    key = "value-bank-4567/envs/development/01-infra/eks-development-value-bank-4567/03-eks/terraform.tfstate"
    region = "ap-south-1"
    role_arn = "arn:aws:iam::474532148129:role/XLR8sDemoAssumerRole"
  }
}
