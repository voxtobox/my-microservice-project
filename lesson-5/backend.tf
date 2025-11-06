terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-vao-01"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

