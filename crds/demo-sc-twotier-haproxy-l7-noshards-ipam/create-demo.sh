#!/bin/bash

(cd cis-config ; ./deploy-cis.sh )
oc -n cis-sc-twotier get deployments

(cd routes-router ; ./create-routes-router.sh)
oc -n sc-twotier get route

(cd routes-bigip ; ./create-routes-bigip.sh)
oc -n openshift-ingress get route


