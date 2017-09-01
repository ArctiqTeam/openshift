#!/bin/bash

## Author: shea.stewart@arctiq.ca
## This script will export the existing docker-registry route, obtain the self-
## signed certificate that exists in the pod, and generate a reencrypting route
## to leverage the wildcard certificate on the OCP routers to create a
## properly secured connection for external users. Internal processes will
## still access the registry in an insecure manner (ie. using the self-signed)
## certificate.

date=`date +%y%m%d%H%M`
BACKUPFILE=registry_route.backup.$date.yaml
TMPFILE=/tmp/registry-route
oc export route docker-registry -o yaml > $BACKUPFILE
HOSTNAME=$(<$BACKUPFILE  | grep host | awk 'NR==1 {print $2}')
oc exec $(oc get pods | grep Running | grep docker-registry | awk 'NR==1 {print $1}') cat /etc/secrets/registry.crt > $TMPFILE
oc delete route docker-registry
oc create route reencrypt --service docker-registry --dest-ca-cert=$TMPFILE --hostname=$HOSTNAME
rm $TMPFILE
