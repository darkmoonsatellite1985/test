resource "aws_s3_bucket" "terraform_backend_bucket" {
      bucket = "terraform-state-qsq6vzj3vuzphy1u4xxkeupr18v4reiqf4a2pyuwn4n74"
}

terraform {
  required_providers {
    aws =  {
    source = "hashicorp/aws"
    version = ">= 2.7.0"
    }
  }
}

provider "aws" {
    region = "us-west-2"
}

