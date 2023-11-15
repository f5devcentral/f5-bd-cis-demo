#!/bin/bash

oc apply -f service-router-shard-apps.yaml


for s in a b c d ; do

        oc apply -f route-$s.yaml

done

