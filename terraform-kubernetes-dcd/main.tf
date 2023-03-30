terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      version = "= 6.3.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "ionoscloud" {
  endpoint = var.ionos_api_url
}

variable "kubeconfig" {
  type = string
  default = "../terraform/kubeconfig-ionos.yaml"
}

provider "kubernetes" {
  config_path    = "${var.kubeconfig}"
  config_context = "cluster-admin@federated-catalog"
}

provider "helm" {
  kubernetes {
    config_path    = "${var.kubeconfig}"
  }
}

provider "kubectl" {
  config_path    = "${var.kubeconfig}"
}

variable "domain" {
  default = "example.com"
}

module "nginx_ingress" {
  source = "./nginx_ingress"

}

module "cert_manager" {
  source = "./cert_manager"

  depends_on = [
    module.nginx_ingress
  ]
}

module "infrastructure_services" {
  source = "./infrastructure_services"

  depends_on = [
    module.cert_manager
  ]

  domain = "${var.domain}"
}

module "certificate_issuer" {
  source = "./certificate_issuer"

  depends_on = [
    module.infrastructure_services
  ]
}

module "federated_catalogue" {
  source = "./federated_catalogue"

  depends_on = [
    module.certificate_issuer
  ]

  domain = "${var.domain}"
}