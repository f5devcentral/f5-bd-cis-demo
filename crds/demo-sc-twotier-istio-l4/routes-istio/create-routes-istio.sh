#!/bin/bash

oc create ns sc-istio

kubectl create -n istio-system secret tls sc-istio-credential \
  --key=Certificate-for-sc-istio-com.key \
  --cert=Certificate-for-sc-istio-com.crt

oc apply -f istio-gateway.yaml
oc apply -f istio-virtualservice-www.yaml
oc apply -f istio-virtualservice-account.yaml

for n in a b c d ; do
	oc apply -f route-$n-svc.yaml
done


