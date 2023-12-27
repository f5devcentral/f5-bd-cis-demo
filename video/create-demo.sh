#!/bin/bash

set -x

(cd cis-config ; ./deploy-cis.sh ; ./deploy-ipam.sh )
run-clusters.sh oc -n cis-mc-twotier get deployments

(cd routes-router; ./create-routes-router.sh)
run-clusters.sh oc -n applications get route

(cd routes-bigip ; ./create-routes-bigip.sh)
run-clusters.sh oc -n openshift-ingress get vs


