#!/bin/bash

set -x

(cd cis-config ; ./deploy-cis.sh ; ./deploy-ipam.sh )
CLUSTER_LIST="ocp1 ocp2" run-clusters.sh oc -n cis-mc-twotier get deployments

(cd routes-istio ; for cluster in ocp1 ocp2 ocp3 ; do ./create-routes-istio.sh $cluster ; done )
CLUSTER_LIST="ocp1 ocp2 ocp3" run-clusters.sh oc -n mc-twotier get virtualservice

(cd routes-bigip ; CLUSTER_LIST="ocp1 ocp2 ocp3" run-clusters.sh ./create-services-bigip.sh)
(cd routes-bigip ; CLUSTER_LIST="ocp1 ocp2" run-clusters.sh ./create-routes-bigip.sh)
CLUSTER_LIST="ocp1 ocp2" run-clusters.sh oc -n istio-system get vs

