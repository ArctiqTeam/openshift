#!/bin/sh
## Export all project data for reference and re-import
## created by Shea Stewart shea.stewart@arctiq.ca
d=`date +%y%m%d%H%M%S`
mkdir ~/ose_project_export_$d
cd ~/ose_project_export_$d
oc get project | awk 'FNR>1 {print $1}' > project_list
for n in $(cat project_list); 
    do 
        oc project $n
        oc export svc,sa,dc,bc,route,rc,is,templates -o yaml --exact > ${n}_exact.yaml
        oc export svc,sa,dc,bc,route,rc,is,templates -o yaml --raw > ${n}_raw.yaml
        oc export svc,sa,dc,bc,route,rc,is,templates -o yaml > ${n}_for_import.yaml
    done
