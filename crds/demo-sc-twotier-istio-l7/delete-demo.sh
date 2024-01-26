#!/bin/bash

(cd routes-bigip ; ./delete-routes-bigip.sh)

(cd routes-istio ; ./delete-routes-istio.sh)

(cd cis-config ; ./undeploy-ipam.sh ; ./undeploy-cis.sh )


