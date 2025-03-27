terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "gopal-kra-assignment"
    key            = "statefile/infra-automtion-terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-file"
  }
}

provider "aws" {
  region = "ap-south-1"
}