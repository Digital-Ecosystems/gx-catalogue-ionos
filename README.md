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
- IONOS DCD Account
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
export IONOS_TOKEN="" # curl -s -u 'USERNAME:PASSWORD' https://api.ionos.com/auth/v1/tokens/generate | jq -r '.token'

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

You can skip this step if you already have a Kubernetes cluster.

To create the necessary infrastructure run the script ```build-cloud-landscape``` in ```../terraform``` directory. Terraform will generate the `kubeconfig-ionos.yaml` which contain the KUBECONFIG for the cluster. 
```sh
cd ../terraform-kubernetes-dcd
./build-cloud-landscape.sh
```

### 2. Install and configure `external-dns`

(Optional) If you already have a Kubernetes cluster and have skipped step1 of this deployment procedure, you must configure the path to the KUBECONFIG like so:

```sh
export TF_VAR_kubeconfig="path/to/kubeconfig"
```

Return to the ```federated-catalogue``` directory

```sh
cd ../federated-catalogue
```

To install the DNS service you must first create secret containing service account credentials for one of the providers ( AWS, GCP, Azure, ... ) and configure it in the values file - ```../helm/external-dns/values.yaml```. After that install the service with helm.

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install -n external-dns external-dns bitnami/external-dns -f ../helm/external-dns/values.yaml --create-namespace --version 6.14.1

# wait for external-dns POD to become ready
kubectl wait pods -n external-dns -l app.kubernetes.io/name=external-dns --for condition=Ready --timeout=300s
```

### 3. Install the Federated-Catalogue services

To install the other services run the script ```deploy-services.sh``` in ```terraform-kubernetes-dcd``` directory.

```sh
cd terraform-kubernetes-dcd
./deploy-services.sh
```

### References

Documentation for the [IONOS Cloud API](https://api.ionos.com/docs/)  
Documentation for the [IONOSCLOUD Terraform provider](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/latest/docs/)   