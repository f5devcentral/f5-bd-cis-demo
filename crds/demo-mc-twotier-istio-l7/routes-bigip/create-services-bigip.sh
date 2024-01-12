#!/bin/bash

for i in a b c d ; do

        oc apply -f service-route-$i.yaml

done


