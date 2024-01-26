#!/bin/bash

for s in a b c d ; do

	oc delete -f service-router-shard-apps-route-$s.yaml
        oc delete -f route-$s.yaml

done

oc delete -f reencrypt-tls.yaml

