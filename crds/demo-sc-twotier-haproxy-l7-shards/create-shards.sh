#!/bin/bash

(cd router-config ; ./create-shards.sh )
watch oc -n openshift-ingress get deployments

