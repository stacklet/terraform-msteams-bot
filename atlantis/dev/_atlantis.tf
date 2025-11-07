terraform {
  backend "s3" {
    bucket  = "stacklet-terraform-ci-backend"
    key     = "tfstate/dev/terraform-msteams-bot/terraform.tfstate"
    region  = "us-east-2"
    profile = "Test-Runner"
  }

  required_version = ">= 1"
}
