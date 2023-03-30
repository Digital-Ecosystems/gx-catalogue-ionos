resource "helm_release" "nginx-ingres" {
  name       = "nginx-ingress"

  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  namespace = "nginx-ingress"
  version    = "0.16.2"

  create_namespace = true
}