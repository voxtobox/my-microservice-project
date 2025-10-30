terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-vao-01"# Назва S3-бакета
    key            = "lesson-5/terraform.tfstate"   # Шлях до файлу стейту
    region         = "us-west-1"                    # Регіон AWS
    dynamodb_table = "terraform-locks"              # Назва таблиці DynamoDB
    encrypt        = true                           # Шифрування файлу стейту
  }
}