# Helm charts

This directory contains required Helm charts and Helm values for the deployment of the Federated Catalogue.

## Manually deploying the Federated Catalogue to a Kubernetes cluster

The Federated Catalogue can be deployed to a Kubernetes cluster using the Helm charts in this directory.

### Requirements
- [Helm](https://helm.sh/docs/intro/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Kubernetes cluster](https://kubernetes.io/docs/setup/)

### Deploy

1. Install nginx ingress controller

```bash
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install -n nginx-ingress nginx-ingress nginx-stable/nginx-ingress --create-namespace --version 0.16.2
```

2. Install external-dns
```bash
kubectl create namespace external-dns
# Configure provider and credentials in ./external-dns/values.yaml
vim ./external-dns/values.yaml
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install -n external-dns external-dns bitnami/external-dns -f ./external-dns/values.yaml --version 6.14.1
```

3. Install cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
# Install CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
# Install cert-manager
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.11.0 \
  --create-namespace
# Create a ClusterIssuer
kubectl apply -f cert-manager/cluster-issuer.yaml
```

4. Install postgresql

```bash
helm install -n federated-catalogue postgres -f postgres/values.yaml postgres/ --create-namespace
```

5. Install keycloak

```bash
helm install -n federated-catalogue keycloak -f keycloak/values.yaml keycloak/ --create-namespace
```

6. Install neo4j

```bash
helm install -n federated-catalogue neo4j -f neo4j/values.yaml neo4j/ --create-namespace
```

7. Install the Federated Catalogue service

```bash
helm install -n federated-catalogue fc -f fc/values.yaml fc/ --create-namespace
```

8. Install the demo portal

```bash
helm install -n federated-catalogue demo-portal -f demo-portal/values.yaml demo-portal/ --create-namespace
```
