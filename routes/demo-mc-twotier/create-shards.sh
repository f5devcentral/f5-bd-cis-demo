#!/bin/bash

(cd router-config ; ./create-shards.sh )
watch run-clusters.sh oc -n openshift-ingress get deployments

