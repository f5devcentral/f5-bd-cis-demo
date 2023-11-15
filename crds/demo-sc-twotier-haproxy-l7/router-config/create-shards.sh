#!/bin/bash

oc -n openshift-ingress-operator patch ingresscontroller default --patch-file=router-default.shard.json --type=merge

oc apply -f router-shard-apps.yaml

