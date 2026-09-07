# Frontend stack — S3 + CloudFront for the Vite/React SPA

locals {
  # Use explicit aliases when set; otherwise derive from dns_record_name so SSL/DNS stay in sync.
  cloudfront_aliases = length(var.cloudfront_aliases) > 0 ? var.cloudfront_aliases : (
    var.dns_record_name != "" ? [var.dns_record_name] : []
  )
}

check "acm_certificate_with_custom_domain" {
  assert {
    condition     = length(local.cloudfront_aliases) == 0 || var.acm_certificate_arn != null
    error_message = "acm_certificate_arn must be set when cloudfront_aliases or dns_record_name configures a custom domain."
  }
}

# 1. Naya Route53 Hosted Zone jo imranlearn.online ke liye generate hoga
resource "aws_route53_zone" "new_zone" {
  name          = var.dns_zone_name
  force_destroy = var.dns_zone_force_destroy
}

# 2. Fresh SSL Certificate us-east-1 (N. Virginia) me naye domain ke liye
resource "aws_acm_certificate" "cloudfront_cert" {
  count             = length(local.cloudfront_aliases) > 0 ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = local.cloudfront_aliases[0]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Naye Route53 zone ke andar validation records create karna
resource "aws_route53_record" "cert_validation" {
  for_each = length(local.cloudfront_aliases) > 0 ? {
    for dvo in aws_acm_certificate.cloudfront_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.new_zone.zone_id # Naye zone ki ID use ho rahi hai
}

# 4. Pipeline waiting loop jab tak certificate status ISSUED nahi ho jata
resource "aws_acm_certificate_validation" "cert" {
  count                   = length(local.cloudfront_aliases) > 0 ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cloudfront_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

module "cloudfront" {
  source = "../modules/cloudfront"

  application       = var.application
  environment       = var.environment
  bucket_name       = var.bucket_name
  force_destroy     = var.force_destroy
  enable_versioning = var.enable_versioning
  enable_spa_routing  = var.enable_spa_routing

  aliases             = local.cloudfront_aliases
  acm_certificate_arn = length(local.cloudfront_aliases) > 0 ? aws_acm_certificate_validation.cert[0].certificate_arn : null

  depends_on = [aws_acm_certificate_validation.cert] 
}

module "route53" {
  source = "../modules/route53"

  application = var.application
  environment = var.environment
  tags = {
    Component = "route53"
  }

  zone_name     = var.dns_zone_name
  zone_id       = aws_route53_zone.new_zone.zone_id # Naye zone ki ID auto-pass ho rahi hai
  force_destroy = var.dns_zone_force_destroy

  records = var.dns_record_name != "" ? [
    {
      name = var.dns_record_name
      type = "A"
      alias = {
        name    = module.cloudfront.domain_name
        zone_id = module.cloudfront.hosted_zone_id
      }
    },
    {
      name = var.dns_record_name
      type = "AAAA"
      alias = {
        name    = module.cloudfront.domain_name
        zone_id = module.cloudfront.hosted_zone_id
      }
    },
  ] : []
}
