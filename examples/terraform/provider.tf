provider "aws" {
    region = "${var.AWS_REGION}"
}

terraform {
  backend "remote" {
    organization = "Organization"

    workspaces {
      name = "platform-qa"
    }
  }
}
