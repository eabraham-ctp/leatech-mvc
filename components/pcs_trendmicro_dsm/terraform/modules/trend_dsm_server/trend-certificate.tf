resource "tls_private_key" "registry" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "registry" {
  key_algorithm   = "${tls_private_key.registry.algorithm}"
  private_key_pem = "${tls_private_key.registry.private_key_pem}"

  subject {
    organization = "Trend Micro Inc."
    country      = "CA"
    province     = "Ontario"
    locality     = "Ottawa"
  }
  validity_period_hours = 43800
  is_ca_certificate = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "cert_signing"
  ]
}

resource "aws_iam_server_certificate" "registry" {
  name             = "${lower(var.org)}-${lower(var.group)}-${lower(var.environment)}-trendmicro-self-signed-cert"
  certificate_body = "${tls_self_signed_cert.registry.cert_pem}"
  private_key      = "${tls_private_key.registry.private_key_pem}"

  lifecycle {
    create_before_destroy = true
  }
}
