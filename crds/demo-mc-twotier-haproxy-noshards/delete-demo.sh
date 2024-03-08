#!/bin/bash

(cd routes-bigip ; for cluster in ocp1 ocp2 ; do ./delete-routes-bigip.sh $cluster ; done )

(cd routes-router ; for cluster in ocp1 ocp2 ; do ./delete-routes-router.sh $cluster ; done )

(cd cis-config ; ./undeploy-cis.sh )

