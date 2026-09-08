# Remote state: S3 + DynamoDB locking
#
# Initialize with:
#   cp backend.hcl.example backend.hcl   # edit bucket/region if needed
#   terraform init -backend-config=backend.hcl

terraform {
  backend "s3" {
    bucket = "imran-cdec-frontend-tfstate-euwest1"
    key    = "backend/terraform.tfstate"
    region = "ap-south-1"
    #profile = "terraform-sessions"

  }
}
