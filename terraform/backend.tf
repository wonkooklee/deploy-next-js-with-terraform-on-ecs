terraform {
  backend "s3" {
    bucket  = "s3-bucket-tfstate-2308ru2308fuwe"
    key     = "terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
}
