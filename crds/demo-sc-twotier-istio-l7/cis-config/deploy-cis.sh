#!/bin/bash

POOLMEMBER_TYPE=clusterip

oc create ns cis-sc-twotier

kubectl apply -f bigip-ctlr-clusterrole.yaml
oc adm policy add-cluster-role-to-user cluster-admin -z bigip-ctlr -n cis-sc-twotier

kubectl apply -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/master/docs/config_examples/customResourceDefinitions/incubator/customresourcedefinitions.yml

oc create secret generic bigip-login --namespace cis-sc-twotier --from-literal=username=admin --from-literal=password=OpenShiftMC

for BIGIP in 1 2; do

	oc apply -f f5-bigip${BIGIP}-ctlr-deployment.${POOLMEMBER_TYPE}.yaml 
done

