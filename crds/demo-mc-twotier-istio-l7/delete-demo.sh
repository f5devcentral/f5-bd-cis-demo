#!/bin/bash

(cd routes-bigip ; CLUSTER_LIST="ocp1 ocp2" run-clusters.sh ./delete-routes-bigip.sh)
(cd routes-bigip ; CLUSTER_LIST="ocp1 ocp2 ocp3" run-clusters.sh ./delete-services-bigip.sh)

(cd routes-istio ; CLUSTER_LIST="ocp1 ocp2 ocp3" run-clusters.sh ./delete-routes-istio.sh)

(cd cis-config ; ./undeploy-ipam.sh ; ./undeploy-cis.sh)
