provider "aws" {
  region = "ap-southeast-2" # Your main deployment region
}

# Add this required alias for the CloudFront SSL certificate
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
