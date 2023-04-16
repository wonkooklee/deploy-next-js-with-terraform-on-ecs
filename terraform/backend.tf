terraform {
  backend "s3" {
    bucket         = "wonkook-backend-tfstate-bucket"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-lock"
    region         = "ap-northeast-2"
    encrypt        = true
  }
}
