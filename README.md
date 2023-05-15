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

***

## Configuration
Set environment variables

```sh
# copy .env-template to .env and set the values of the required parameters
cp .env-template .env

# load the configuration
source .env
```

***

## Deploy


### 1. Create Kubernetes cluster

Follow [these instructions](https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster) to create Kubernetes cluster with installed **cert-manager**, **NGINX ingress**, and optionally **external-dns**.

### 2. Install and configure `external-dns` (Optional)

Skip this step if you want to use Ionos DNS service.


If you already have a Kubernetes cluster and have skipped step1 of this deployment procedure, you must configure the path to the KUBECONFIG like so:

```sh
export TF_VAR_kubeconfig="path/to/kubeconfig"
```

and set ```USE_IONOS_DNS``` variable to False:
```sh
export USE_IONOS_DNS=False
```

Follow [these instructions](https://github.com/Digital-Ecosystems/ionos-kubernetes-cluster) for **external-dns**.

### 3. Use Ionos DNS service (Optional)

In order to use the DNS service, you should have skipped step 2 and you will need NS record pointing to Ionos name servers

```
ns-ic.ui-dns.com
ns-ic.ui-dns.de
ns-ic.ui-dns.org
ns-ic.ui-dns.biz
```

You will also need to set ```USE_IONOS_DNS``` variable to True:
```sh
export USE_IONOS_DNS=True
```
If you have DNS zone already configured set ```IONOS_DNS_ZONE_ID``` environment variable.

### 4. Install the Federated-Catalogue services

To install the other services run the script ```deploy-services.sh``` in ```terraform``` directory.

```sh
cd terraform
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

### 6. Uninstall

To uninstall the federated-catalogue services run the script ```uninstall-services.sh``` in ```terraform``` directory.

```sh
./uninstall-services.sh
```

### References

Documentation for the [IONOS Cloud API](https://api.ionos.com/docs/)  
Documentation for the [IONOSCLOUD Terraform provider](https://registry.terraform.io/providers/ionos-cloud/ionoscloud/latest/docs/)