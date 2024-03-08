#!/bin/bash

CLUSTER_ALIAS=$1
use-cluster.sh $CLUSTER_ALIAS

oc delete -f reencrypt-tls.yaml

for s in a b c d ; do

	oc delete -f service-route-$s.$CLUSTER_ALIAS.yaml
done

for s in a b c d ; do

	oc delete -f route-$s.yaml
done

