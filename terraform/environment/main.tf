terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "terraform-state-cors-api"
    region = "eu-west-3"
    key = "terraform.tfstate"
  }
}

provider "aws" {
  region  = "eu-west-3"
  version = "~> 3.29"
}