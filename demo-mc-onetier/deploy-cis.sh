#!/bin/bash

set -x

(cd cis-config ; ./deploy-cis.sh )
run-clusters.sh oc -n cis-mc-onetier get deployments



