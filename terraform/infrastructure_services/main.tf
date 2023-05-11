# install helm postgresql
resource "helm_release" "postgres" {
  name       = "postgres"

  repository = "../deployment/helm"
  chart      = "postgres"

  namespace = "federated-catalogue"
  create_namespace = true

  values = [
    "${file("../deployment/helm/postgres/values.yaml")}"
  ]
}

# install helm keycloak
variable "domain" {
  default = "example.com"
}
resource "helm_release" "keycloak" {
  name       = "keycloak"

  repository = "../deployment/helm"
  chart      = "keycloak"

  namespace = "federated-catalogue"
  create_namespace = true

  values = [
    "${file("../deployment/helm/keycloak/values.yaml")}"
  ]

  set {
    name  = "ingress.hosts[0].host"
    value = "fc-key-server.${var.domain}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "fc-key-server.${var.domain}"
  }
  set {
    name  = "keycloak.federatedCatalogueClientRedirectUris[0]"
    value = "https://fc-demo-portal.${var.domain}/*"
  }
  set {
    name  = "keycloak.hostname"
    value = "fc-key-server.${var.domain}"
  }
}

# helm install -n federated-catalogue neo4j -f neo4j/values.yaml neo4j/neo4j
resource "helm_release" "neo4j" {
  name       = "neo4j"

  repository = "../deployment/helm"
  chart      = "neo4j"

  namespace = "federated-catalogue"
  create_namespace = true

  values = [
    "${file("../deployment/helm/neo4j/values.yaml")}"
  ]
}