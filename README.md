***
# Federated Catalogue deployment

This document describes how to deploy the Federated Catalogue on IONOS DCD.

***
These are the services that are deployed:

- [Demo Portal](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/tree/main/demo-portal): A demo portal to showcase the Federated Catalogue.
- [Federated Catalogue](https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service/-/tree/main/fc-service-server): The Federated Catalogue service.
- [Keycloak](https://www.keycloak.org/): An open source identity and access management solution.
- [Neo4j](https://neo4j.com/): A graph database management system.
- [PostgreSQL](https://www.postgresql.org/): Open source object-relational database system.

***


## Requirements

Before you start deploying the Federated Catalogue, make sure you meet the requirements:
- Kubernetes cluster with installed **cert-manager**, **NGINX ingress** and **external-dns**
- Terraform
- kubectl
- Docker
- Helm
- DNS server and domain name

## Configuration

Set environment variables

```sh
# Required configuration
export TF_VAR_domain='federated-catalogue.example.com'
export TF_VAR_kubeconfig='~/.kube/config'

# Optional configuration
export TF_VAR_datacenter_name='Digital Ecosystems'
export TF_VAR_kubernetes_cluster_name='federated-catalogue'
export TF_VAR_datacenter_location='de/txl'
export IONOS_API_URL="api.ionos.com"
export TF_LOG=debug
export IONOS_LOG_LEVEL=debug

# Optional configuration for the Kubernetes resource allocation
export TF_VAR_node_memory=8192
export TF_VAR_node_count=2
export TF_VAR_cores_count=2
```

***
## Deploy


### 1. Create Kubernetes cluster

To create a Kubernetes cluster on IONOS cloud with installed **cert-manager** and **external-dns** follow the steps in [ionos-kubernetes-cluster](https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster) repository.

### 2. Install the Federated-Catalogue services

To install the other services run the script ```deploy-services.sh``` in ```terraform-kubernetes-dcd``` directory.

```sh
cd terraform-kubernetes-dcd
./deploy-services.sh
```

### References

Documentation for the [IONOS Cloud API](https://api.ionos.com/docs/)  
Documentation for the [IONOSCLOUD Terraform provider](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/latest/docs/)   