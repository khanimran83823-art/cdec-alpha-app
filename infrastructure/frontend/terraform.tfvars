# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region  = "eu-west-1"
environment = "dev"
application = "cdec-alpha"

# Isse null kar dein kyunki code khud fresh certificate banayega
acm_certificate_arn = "arn:aws:acm:us-east-1:147741822158:certificate/0a419ca2-cc77-4226-95b5-a01376f63313"

dns_zone_name      = "imranlearn.online"
dns_record_name    = "www.imranlearn.online"   
cloudfront_aliases = ["www.imranlearn.online"]
