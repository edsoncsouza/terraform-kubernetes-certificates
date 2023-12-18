# https://kubernetes.io/docs/setup/best-practices/certificates/
module "kubernetes_root_ca" {
  source      = "git::github.com/edsoncsouza/vishwakarma.git//modules/tls/certificate-authority"
  self_signed = true
  cert_config = {
    common_name           = "kubernetes-root-ca"
    organization          = "kubernetes"
    validity_period_hours = "26280"
  }
}

module "ca" {
  source = "git::github.com/edsoncsouza/vishwakarma.git//modules/tls/certificate-authority"
  for_each = {
    kubernetes_ca = {
      common_name  = "kubernetes-ca"
      organization = "kubernetes"
    },
    etcd_ca = {
      common_name  = "etcd-ca"
      organization = "etcd"

    },
    kubernetes_front_proxy_ca = {
      common_name  = "kubernetes-front-proxy-ca"
      organization = "kubernetes-front-proxy"
    },
  }
  self_signed = false
  ca_config = {
    key_pem  = module.kubernetes_root_ca.private_key_pem
    cert_pem = module.kubernetes_root_ca.cert_pem
  }
  cert_config = {
    common_name           = lookup(each.value, "common_name", "")
    organization          = lookup(each.value, "organization", "")
    validity_period_hours = lookup(each.value, "validity_period_hours", "26280")
  }
}
