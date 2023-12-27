#!/bin/bash

(cd routes-bigip ; ./delete-routes-bigip.sh)

(cd routes-router ; ./delete-routes-router.sh)

(cd cis-config ; ./undeploy-ipam.sh ; ./undeploy-cis.sh )


