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
- Terraform
- kubectl
- Docker
- Helm
- DNS server and domain name
- Kubernetes cluster with installed **cert-manager**, **NGINX ingress**, and **external-dns**

## Configuration

Set environment variables

```sh
# Required configuration
export TF_VAR_domain='federated-catalogue.example.com'
export TF_VAR_kubeconfig="path/to/kubeconfig"

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

Follow [these instructions](https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster) to create Kubernetes cluster with installed **cert-manager**, **NGINX ingress**, and optionally **external-dns**.

### 2. DNS

#### Option 1 - `external-dns`

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

#### Option 2 - `manual` DNS entries

If your DNS service is not available as provider in **external-dns**, you must create the DNS entries manually. Create the following DNS entries:

A record for ```fc-demo-portal.<DOMAIN>``` pointing to the IP address of the Ingress IP in the Kubernetes cluster.
A record for ```fc-key-server.<DOMAIN>``` pointing to the IP address of the Ingress IP in the Kubernetes cluster.

To get assigned IP address to the Ingress svc, run the following command:

```sh
kubectl -n nginx-ingress get service nginx-ingress-nginx-ingress
```

### 3. Install the Federated-Catalogue services

To install the other services run the script ```deploy-services.sh``` in ```ionos-kubernetes-dcd``` directory.

```sh
cd ionos-kubernetes-dcd
./deploy-services.sh
```

### 4. Create user

Open the Keycloak admin console in your browser ```https://fc-key-server.<DOMAIN>/admin/master/console/#/create/user/gaia-x``` and login with ```admin/admin```.

**Note:** Replace ```<DOMAIN>``` with the domain name you have set in the environment variable ```TF_VAR_domain```.

Fill in the form and click on **Save**. Make sure "Email Verified" is set to **ON**.

Next click on **Credentials** and set a password for the user.

After that click on **Role Mappings**. On **Client Roles** dropdown select **federated-catalogue** and move **Ro-MU-A**, **Ro-MU-CA**, **Ro-PA-A**, and **Ro-SD-A** to **Assigned Roles**.

### 5. Access the demo portal

Go to ```https://fc-demo-portal.<DOMAIN>``` and login with the user you have created in the previous step.

**Note:** Replace ```<DOMAIN>``` with the domain name you have set in the environment variable ```TF_VAR_domain```.

### References

Documentation for the [IONOS Cloud API](https://api.ionos.com/docs/)  
Documentation for the [IONOSCLOUD Terraform provider](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/latest/docs/)