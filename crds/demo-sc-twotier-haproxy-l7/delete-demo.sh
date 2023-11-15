#!/bin/bash

(cd routes-bigip ; ./delete-routes-bigip.sh)

(cd routes-router ; ./delete-routes-router.sh)

(cd cis-config ; ./undeploy-cis.sh )


