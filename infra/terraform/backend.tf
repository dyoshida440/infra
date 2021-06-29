terraform {
  backend "s3" {
    bucket         = "tfstate-infra-dyoshida"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "tfstate-lock-infra-dyoshida"
  }
}
