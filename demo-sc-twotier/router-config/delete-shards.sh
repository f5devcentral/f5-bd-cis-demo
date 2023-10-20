#!/bin/bash

oc -n openshift-ingress-operator patch ingresscontroller default --patch-file=router-default.orig.json --type=json

for s in a b c d ; do

	oc delete -f router-shard-$s.yaml
done

