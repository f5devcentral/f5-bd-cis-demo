#!/bin/bash

set -x

(cd cis-config ; ./deploy-cis.sh )
run-clusters.sh oc get deployments -n cis-mc-twotier

(cd routes-router ; ./create-routes-router.sh)
run-clusters.sh oc -n mc-twotier-shard-mc get route

(cd routes-bigip ; ./create-routes-bigip.sh)
run-clusters.sh oc -n openshift-ingress get route


