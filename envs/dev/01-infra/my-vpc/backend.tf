
terraform {
  backend "s3" {	
    bucket = "xlr8s-artifacts"
    encrypt = "false"
    key = "xlr8s-demo-9723/envs/dev/01-infra/my-vpc/terraform.tfstate"
    region = "ap-south-1"
    role_arn = ""
  }
}
