#!/bin/bash

if [ -z `printenv TF_VAR_domain` ]; then
    echo "Stopping because TF_VAR_domain is undefined"
    exit 1
fi  

if [ -z `printenv USE_IONOS_DNS` ]; then
    echo "Stopping because USE_IONOS_DNS is undefined"
    exit 1
fi  

if [ -z `printenv TF_VAR_kubeconfig` ]; then
    echo "Stopping because TF_VAR_kubeconfig is undefined"
    exit 1
fi  

# This script is used to build the cloud landscape for the federated catalogue.
terraform destroy -auto-approve

if [ $USE_IONOS_DNS == True ]; then
    if [ -z `printenv IONOS_DNS_ZONE_ID` ]; then
        DNS_ZONE_ID=$(curl -X "GET" \
    -H "accept: application/json" \
    -H "Authorization: Bearer $IONOS_TOKEN" \
    -H "Content-Type: application/json" \
    "https://dns.de-fra.ionos.com/zones" |jq -r ".items[] | select(.properties[\"zoneName\"] == \"$TF_VAR_domain\") | .id")
        
        if [ $? != 0 ]; then
            echo "Getting zone id failed"
            exit 1
        fi
    else
        DNS_ZONE_ID=$IONOS_DNS_ZONE_ID
    fi

    curl -X "DELETE" \
        -H "accept: application/json" \
        -H "Authorization: Bearer $IONOS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dns.de-fra.ionos.com/zones/$DNS_ZONE_ID"

    if [ $? != 0 ]; then
        echo "DNS zone deletion failed"
        exit 1
    else
        echo "DNS zone $DNS_ZONE_ID deleted"
    fi

fi

kubectl delete namespace federated-catalogue
