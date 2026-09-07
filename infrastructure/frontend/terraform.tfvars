# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region  = "eu-west-1"
environment = "dev"
application = "cdec-alpha"

acm_certificate_arn = "arn:aws:acm:us-east-1:933516006319:certificate/fd6dd327-9040-4390-b756-672c18a25ff3"

dns_zone_name      = "imranlearn.online"
dns_record_name    = "www.imranlearn.online"    # Ya fir agar seedhe naked domain chahiye toh sirf "imranlearn.online"
cloudfront_aliases = ["www.imranlearn.online"]
