## change_router_default_cert.sh script
This script is intended to replace the default SSL certificate assigned to the OpenShift router pods. It will also add the default certificate into the REGISTRY CONSOLE pod. 

This process can be performed without service disruption, rather than re-deploying the routers (which has a service impact)

The SSL certificate contents are mounted as a secret inside of the router pods, which this script will replace and re-deploy

You must have cluster-admin privileges, and this assumes the router deployment config has the default name

Pass the new certificate file names in this order: NEW_CERT NEW_PRIVATE_KEY NEW_CA_CERT
ie. ./change_router_default_cert.sh apps_cert.crt apps_key.key ca_cert.crt
