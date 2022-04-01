
terraform {
  backend "s3" {	
    bucket = "xlr8s-artifacts"
    encrypt = "false"
    key = "envs/dev/01-infra/my-vpc/terraform.tfstate"
    region = "ap-south-1"
    role_arn = ""
  }
}
