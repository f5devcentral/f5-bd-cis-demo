#!/bin/bash

cluster=$1

use-cluster.sh $cluster

oc create ns mc-twotier

kubectl create -n mc-twotier secret tls mc-twotier-credential \
  --key=mc-nginx-com.key \
  --cert=mc-nginx-com.crt

for n in a b c d ; do
	oc apply -f svc-route-$n.$cluster.yaml
done

oc apply -f routes.yaml
