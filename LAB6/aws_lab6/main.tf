terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "my-tf-state-simple-sasha"
    key     = "terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------
# Random ID for bucket uniqueness
# -----------------
resource "random_id" "bucket_id" {
  byte_length = 4
}

# -----------------
# EC2 Instance
# -----------------
resource "aws_instance" "webserver" {
  ami           = "ami-04e601abe3e1a910f" # Amazon Linux 2 (eu-central-1)
  instance_type = "t3.micro"

  tags = {
    Name = "WebServer-${var.env}"
  }
}

# -----------------
# S3 Bucket
# -----------------
resource "aws_s3_bucket" "simple_bucket" {
  bucket = "my-simple-bucket-${var.env}-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Name = "simple-bucket-${var.env}"
  }
}
