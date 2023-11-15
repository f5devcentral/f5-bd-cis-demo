#!/bin/bash

set -x

(cd cis-config ; ./deploy-cis.sh )
run-clusters.sh oc -n cis-shards get deployments

(cd routes-router ; ./create-routes-router.sh)
run-clusters.sh oc -n mc-shard-router get route

(cd routes-bigip ; ./create-routes-bigip.sh)
run-clusters.sh oc -n openshift-ingress get route


