#!/bin/bash

oc apply -f reencrypt-tls.yaml

for s in a b c d ; do

	oc apply -f service-router-shard-apps-route-$s.yaml
        oc apply -f route-$s.yaml

done

