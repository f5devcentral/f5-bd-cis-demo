#!/bin/bash

(cd cis-config ; ./deploy-cis.sh )
oc -n cis-shards get deployments

(cd routes-router ; ./create-routes-router.sh)
for s in a b c d; do oc -n shard-$s-router get route ; done

(cd routes-bigip ; ./create-routes-bigip.sh)
oc -n openshift-ingress get route


