#!/bin/bash
## Create backup archive of /etc/origin

for node in $(cat node_list); do
  ssh $node 'fullDay=$(date +%Y%m%d); tar -zcf ~/etc.origin.backup.$(date +%Y%m%d).tar /etc/origin/'
done
