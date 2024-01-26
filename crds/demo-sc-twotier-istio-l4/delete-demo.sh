#!/bin/bash -x

(cd transportservers-bigip ; ./delete-transportservers.sh)
oc -n istio-system get ts

(cd routes-istio ; ./delete-routes-istio.sh)

(cd cis-config ; ./undeploy-ipam.sh ; ./undeploy-cis.sh )


