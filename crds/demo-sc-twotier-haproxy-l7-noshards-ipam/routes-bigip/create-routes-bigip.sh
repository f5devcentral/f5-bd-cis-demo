#!/bin/bash

oc apply -f reencrypt-tls.yaml

for s in a b c d ; do

        oc apply -f service-route-$s.yaml

done


for s in a b c d ; do

        oc apply -f route-$s.yaml

done

