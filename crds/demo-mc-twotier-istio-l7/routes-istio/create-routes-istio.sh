#!/bin/bash

oc create ns mc-istio

kubectl create -n istio-system secret tls mc-istio-credential \
  --key=Certificate-for-mc-istio-com.key \
  --cert=Certificate-for-mc-istio-com.crt

oc apply -f istio-gateway.yaml
oc apply -f istio-virtualservice-www.yaml
oc apply -f istio-virtualservice-account.yaml

for n in a b c d ; do
	oc apply -f route-$n-svc.yaml
done


