#!/bin/bash -x

(cd cis-config ; ./deploy-cis.sh ; ./deploy-ipam.sh )
oc -n cis-sc-twotier get deployments

(cd routes-istio ; ./create-routes-istio.sh)
oc -n sc-istio get VirtualService

(cd transportservers-bigip ; ./create-transportservers.sh)
oc -n istio-system get ts

