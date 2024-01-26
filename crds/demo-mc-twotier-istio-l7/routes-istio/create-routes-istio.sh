#!/bin/bash

cluster=$1

use-cluster.sh $cluster

oc create ns mc-twotier

kubectl create -n istio-system secret tls mc-istio-credential \
  --key=Certificate-for-mc-istio-com.key \
  --cert=Certificate-for-mc-istio-com.crt

for n in a b c d ; do
        oc apply -f svc-route-$n.$cluster.yaml
done

oc apply -f istio-gateway.yaml
oc apply -f istio-virtualservice-www.yaml
oc apply -f istio-virtualservice-account.yaml



