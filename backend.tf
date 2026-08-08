terraform {
  backend "s3" {
    bucket         = "agnivega-terraform-state-343770680577"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
