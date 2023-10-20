#!/bin/bash

oc -n openshift-ingress-operator patch ingresscontroller default --patch-file=router-default.shard.json --type=merge

for s in a b c d ; do

	oc apply -f router-shard-$s.yaml
done

