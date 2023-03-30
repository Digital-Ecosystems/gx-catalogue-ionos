#!/bin/bash

if [ -z `printenv TF_VAR_domain` ]; then
    echo "Stopping because TF_VAR_domain is undefined"
    exit 1
fi  


# This script is used to build the cloud landscape for the federated catalogue.
terraform init && terraform refresh && terraform plan && terraform apply -auto-approve
