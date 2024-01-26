#!/bin/bash

for s in a b c d ; do

        oc delete -f route-$s.yaml

done

for s in a b c d ; do

        oc delete -f service-route-$s.yaml

done

oc delete -f reencrypt-tls.yaml

