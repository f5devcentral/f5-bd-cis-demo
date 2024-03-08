#!/bin/bash

set -x

(cd cis-config ; ./deploy-cis.sh )
CLUSTER_LIST="ocp1 ocp2" run-clusters.sh oc -n cis-mc-twotier get deployments

(cd routes-router ; for cluster in ocp1 ocp2 ; do ./create-routes-router.sh $cluster ; done )
CLUSTER_LIST="ocp1 ocp2" run-clusters.sh oc -n mc-twotier get routes 

(cd routes-bigip ; for cluster in ocp1 ocp2 ; do ./create-routes-bigip.sh $cluster ; done )
CLUSTER_LIST="ocp2 ocp1" run-clusters.sh oc -n openshift-ingress get vs
