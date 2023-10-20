#!/bin/bash

for s in a b c d ; do

        oc delete -f route-shard-$s.yaml

done

for s in a b c d ; do

        oc delete -f service-shard-$s.yaml

done


