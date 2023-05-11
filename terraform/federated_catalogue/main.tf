variable "domain" {
  default = "example.com"
}

resource "helm_release" "fc" {
  name       = "fc"

  repository = "../deployment/helm"
  chart      = "fc"

  namespace = "federated-catalogue"
  create_namespace = true

  values = [
    "${file("../deployment/helm/fc/values.yaml")}"
  ]

  set {
    name  = "ingress.hosts[0].host"
    value = "fc.${var.domain}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "fc.${var.domain}"
  }
  set {
    name  = "fc.keycloakAuthServerUrl"
    value = "https://fc-key-server.${var.domain}"
  }
  set {
    name  = "fc.springSecurityOauth2ResourceserverJwtIssuerUri"
    value = "https://fc-key-server.${var.domain}/realms/gaia-x"
  }
}

resource "helm_release" "demo-portal" {
  name       = "demo-portal"

  repository = "../deployment/helm"
  chart      = "demo-portal"

  namespace = "federated-catalogue"
  create_namespace = true

  values = [
    "${file("../deployment/helm/demo-portal/values.yaml")}"
  ]

  wait = false

  set {
    name  = "ingress.hosts[0].host"
    value = "fc-demo-portal.${var.domain}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "fc-demo-portal.${var.domain}"
  }
  set {
    name = "demoPortal.keycloakIssuerUri"
    value = "https://fc-key-server.${var.domain}/realms/gaia-x"
  }
}
