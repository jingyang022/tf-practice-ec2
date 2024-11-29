terraform {
  backend "s3" {
    bucket = "sctp-ce8-tfstate"
    region = "ap-southeast-1"
    key = "Terraform practice_EC2.tfstate"
  }
}