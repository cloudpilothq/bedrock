terraform {
  backend "s3" {
    bucket = "bedrock-tfstate-210965992144"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}
