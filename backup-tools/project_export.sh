#!/bin/sh
## Export all project data for reference and re-import
## created by Shea Stewart shea.stewart@arctiq.ca
## Modified by Cassius John-Adams cassius.john-adams@cbc.ca
## to check for existing backup first, and perform cleanups
fullDay=$(date +%Y%m%d)
if [ ! -d ~/project_exports/ose_project_export_$fullDay ];
    then
    mkdir ~/project_exports/ose_project_export_$fullDay
    cd ~/project_exports/ose_project_export_$fullDay
    oc get project | awk 'FNR>1 {print $1}' > project_list
    for proj in $(cat project_list); 
        do 
            oc project $proj
            oc export svc,sa,dc,bc,route,rc,is,templates -o yaml --exact > ${proj}_exact.yaml
            oc export svc,sa,dc,bc,route,rc,is,templates -o yaml --raw > ${proj}_raw.yaml
            oc export svc,sa,dc,bc,route,rc,is,templates -o yaml > ${proj}_for_import.yaml
        done
else
    echo "Nothing to do.  Project exports has already run once today"
fi
# Cleanup so we don't fill the root folder
# Cleanup for 30 and 31 days ago, on the odd chance that 
# this script didn't run yesterday.
for delDay in 30 31;
    do
    cleanupDay=$(date "--date=${fullDay} -$delDay day" +%Y%m%d)
    if [ ! -d ~/project_exports/ose_project_export_$cleanupDay ];
            then
            echo "Cleaning up ~/project_exports/ose_project_export_$cleanupDay"
            rm -rf ~/project_exports/ose_project_export_$cleanupDay
            echo "Cleanup complete"
    fi
done
