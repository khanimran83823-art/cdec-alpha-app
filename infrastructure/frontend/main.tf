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

# 1. YEH RESOURCE BLOCK ADD KAREIN: Yeh aapke domain ke liye us-east-1 me fresh certificate banayega
resource "aws_acm_certificate" "cloudfront_cert" {
  count             = length(local.cloudfront_aliases) > 0 ? 1 : 0
  provider          = aws.us_east_1 # Hamari provider.tf ka us-east-1 configuration use hoga
  domain_name       = local.cloudfront_aliases[0]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

module "cloudfront" {
  source = "../modules/cloudfront"
  # ... baaki saare parameters bilkul same rahenge ...

  aliases             = local.cloudfront_aliases
  acm_certificate_arn = length(local.cloudfront_aliases) > 0 ? aws_acm_certificate_validation.cert[0].certificate_arn : null
  enable_spa_routing  = var.enable_spa_routing

  # YEH LINE ADD KAREIN: Yeh pipeline ko validate hone tak rok kar rakhega
  depends_on = [aws_acm_certificate_validation.cert] 
}

module "route53" {
  source = "../modules/route53"

  application = var.application
  environment = var.environment

  zone_name     = var.dns_zone_name
  zone_id       = var.route53_zone_id
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

  tags = {
    Component = "route53"
  }
}
