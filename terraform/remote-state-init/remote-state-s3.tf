//use to initialize the remote backend for the environment
provider "aws" {
  region = "eu-west-3"
  version = "~> 3.29"
}

resource "aws_s3_bucket" "terraform-state-backend" {
    bucket = "terraform-state-cors-api"
    acl    = "private"
    
    versioning {
      enabled = true
    }
    lifecycle {
      prevent_destroy = true
    } 
}