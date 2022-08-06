provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_s3_bucket" "qa-FIRSTNAME-LASTNAME-stormreply-platform-challenge" {
  bucket = "qa-FIRSTNAME-LASTNAME-stormreply-platform-challenge-06082022"
  acl    = "private"
}
