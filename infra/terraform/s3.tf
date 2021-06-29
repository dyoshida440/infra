resource "aws_s3_bucket" "tfstate-storage" {
  bucket = "tfstate-infra-dyoshida"
  acl    = "private"

  versioning {
    enabled = true
  }
}
