terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

resource "kubectl_manifest" "certificate_issuer" {
  yaml_body = file("${path.module}/cluster-issuer.yaml")
}