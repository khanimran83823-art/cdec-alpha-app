# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region  = "eu-west-1"
environment = "dev"
application = "cdec-alpha"

# Isse null kar dein kyunki code khud fresh certificate banayega
acm_certificate_arn = null

dns_zone_name      = "imranlearn.online"
dns_record_name    = "www.imranlearn.online"   
cloudfront_aliases = ["www.imranlearn.online"]
