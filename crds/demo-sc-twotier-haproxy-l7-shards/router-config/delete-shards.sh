#!/bin/bash

oc -n openshift-ingress-operator patch ingresscontroller default --patch-file=router-default.orig.json --type=json

oc delete -f router-shard-apps.yaml

