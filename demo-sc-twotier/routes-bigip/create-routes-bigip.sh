#!/bin/bash

for s in a b c d ; do

        oc apply -f service-shard-$s.yaml

done


for s in a b c d ; do

        oc apply -f route-shard-$s.yaml

done

