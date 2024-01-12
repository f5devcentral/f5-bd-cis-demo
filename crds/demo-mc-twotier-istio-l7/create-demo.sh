#!/bin/bash

set -x

(cd cis-config ; ./deploy-cis.sh ; ./deploy-ipam.sh )
run-clusters.sh oc -n cis-mc-twotier get deployments

(cd routes-istio ; CLUSTER_LIST="ocp1 ocp2 ocp3" run-clusters.sh ./create-routes-istio.sh)
run-clusters.sh oc -n mc-shard-router get route

(cd routes-bigip ; CLUSTER_LIST="ocp1 ocp2 ocp3" run-clusters.sh ./create-services-bigip.sh)
(cd routes-bigip ; CLUSTER_LIST="ocp1 ocp2" run-clusters.sh ./create-routes-bigip.sh)


