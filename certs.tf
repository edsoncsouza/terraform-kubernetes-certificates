# https://kubernetes.io/docs/setup/best-practices/certificates/
locals {
  cert_uses = {
    server = ["key_encipherment", "digital_signature", "server_auth"]
    client = ["key_encipherment", "digital_signature", "client_auth"]
  }
}
module "kubernetes_certs" {
  for_each = {
    apiserver_cert = {
      cert_hostnames        = ["localhost", "kubernetes", "kubernetes.default", "kubernetes.default.svc", "kubernetes.default.svc.cluster", "kubernetes.default.svc.cluster.local"]
      cert_ip_addresses     = ["127.0.0.1", "192.168.6.101", "192.168.6.102"]
      common_name           = "kube-apiserver"
      organization          = "kube-master"
      validity_period_hours = "26280"
      cert_uses             = ["server"]

    },
    kube_apiserver_kubelet_client = {
      common_name           = "kube-apiserver-kubelet-client"
      organization          = "system:masters"
      validity_period_hours = "26280"
      cert_uses             = ["client"]
    },
    admin = {
      common_name           = "kubernetes-admin"
      organization          = "system:masters"
      validity_period_hours = "26280"
      cert_uses             = ["client"]
    },
    controller_manager = {
      common_name           = "system:kube-controller-manager"
      organization          = ""
      validity_period_hours = "26280"
      cert_uses             = ["client"]
    },
    scheduler = {
      common_name           = "system:kube-scheduler"
      organization          = ""
      validity_period_hours = "26280"
      cert_uses             = ["client"]
    },
  }

  source = "git::github.com/edsoncsouza/vishwakarma.git//modules/tls/certificate"
  ca_config = {
    key_pem  = module.ca["kubernetes_ca"].private_key_pem
    cert_pem = module.ca["kubernetes_ca"].cert_pem
  }
  self_signed = false
  cert_config = {
    common_name           = lookup(each.value, "common_name", "")
    organization          = lookup(each.value, "organization", "")
    validity_period_hours = lookup(each.value, "validity_period_hours", "26280")
  }
  cert_hostnames    = lookup(each.value, "cert_hostnames", [])
  cert_ip_addresses = lookup(each.value, "cert_ip_addresses", [])
  cert_uses         = distinct(concat([for use in lookup(each.value, "cert_uses", []) : local.cert_uses[use]]...))
}

module "etcd_certs" {
  for_each = {
    kube_etcd = {
      common_name           = "kube-etcd"
      validity_period_hours = "26280"
      cert_uses             = ["client", "server"]
      cert_hostnames        = ["localhost", ]
      cert_ip_addresses     = ["127.0.0.1", "192.168.6.101", "192.168.6.102"]
    },
    kube_etcd_peer = {
      common_name           = "kube-etcd-peer"
      validity_period_hours = "26280"
      cert_uses             = ["client", "server"]
      cert_hostnames        = ["localhost"]
      cert_ip_addresses     = ["127.0.0.1", "192.168.6.101", "192.168.6.102"]
    },
    kube_etcd_healthcheck_client = {
      common_name           = "kube-etcd-healthcheck-client"
      validity_period_hours = "26280"
      cert_uses             = ["client"]
    },
    kube_apiserver_kubelet_client = {
      common_name = "kube-apiserver-kubelet-client"
      cert_uses   = ["client"]
    }
  }


  source = "git::github.com/edsoncsouza/vishwakarma.git//modules/tls/certificate"
  ca_config = {
    key_pem  = module.ca["etcd_ca"].private_key_pem
    cert_pem = module.ca["etcd_ca"].cert_pem
  }
  self_signed = false
  cert_config = {
    common_name           = lookup(each.value, "common_name", "")
    organization          = lookup(each.value, "organization", "")
    validity_period_hours = lookup(each.value, "validity_period_hours", "26280")
  }
  cert_hostnames    = lookup(each.value, "cert_hostnames", [])
  cert_ip_addresses = lookup(each.value, "cert_ip_addresses", [])
  cert_uses         = distinct(concat([for use in lookup(each.value, "cert_uses", []) : local.cert_uses[use]]...))
}
