resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  
  namespace = "cert-manager"
  create_namespace = true
  version = "v1.11.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
}