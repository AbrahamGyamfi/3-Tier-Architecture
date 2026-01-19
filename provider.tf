# Specify Terraform Version
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }

  # Remote state backend configuration
  # Run these commands first to create the resources:
  # aws s3api create-bucket --bucket 3tier-terraform-state-<your-unique-id> --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
  # aws s3api put-bucket-versioning --bucket 3tier-terraform-state-<your-unique-id> --versioning-configuration Status=Enabled
  # aws s3api put-bucket-encryption --bucket 3tier-terraform-state-<your-unique-id> --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
  # aws dynamodb create-table --table-name 3tier-terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region eu-west-1
  
  # backend "s3" {
  #   bucket         = "3tier-terraform-state-unique-id"  # Change this to your unique bucket name
  #   key            = "terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "3tier-terraform-locks"
  #   encrypt        = true
  # }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}