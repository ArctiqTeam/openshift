#!/bin/bash
## This script is intended to replace the default SSL certificate assigned to the
## OpenShift router pods. It will also add the default certificate into the
## REGISTRY CONSOLE pod.

## This process can be peformed without service disruption, rather than
## re-deploying the routers (which has a service impact)

## The SSL certificate contents are mounted as a secret inside of the router pods,
## which this script will replace and re-deploy
## You must have cluster-admin privileges, and this assumes the router deployment
## config has the default name

## Pass the new certificate file names in this order: NEW_CERT NEW_PRIVATE_KEY NEW_CA_CERT
## ie. ./change_router_default_cert.sh apps_cert.crt apps_key.key ca_cert.crt

NEW_CERT="$1"
NEW_PRIVATE_KEY="$2"
NEW_CA_CERT="$3"
NEW_PEM=/tmp/new_cert.cert

date=`date +%y%m%d%H%M`

#Select the project
oc project default

#Backup existing secret data
oc export secret router-certs -o yaml > router-certs.backup.$date.yaml

# Create a pem file with the new files
cat $NEW_CERT $NEW_CA_CERT $NEW_PRIVATE_KEY > $NEW_PEM

# Remove existing secret
oc delete secret router-certs
oc delete secret console-secret

# Create new secret
oc secrets new router-certs tls.crt=$NEW_PEM tls.key=$NEW_PRIVATE_KEY --type='kubernetes.io/tls' --confirm
oc secrets new console-secret $NEW_PEM

# Add volume to registry-console if not already there
oc volume dc/registry-console --remove -m /etc/cockpit/ws-certs.d --confirm
oc volume dc/registry-console --add --type=secret --secret-name=console-secret -m /etc/cockpit/ws-certs.d


# Redeploy router pods
oc rollout latest dc/router

# Clean up temp file
rm $NEW_PEM

# Display running pods for verificaiton
oc get pods
