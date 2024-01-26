#!/bin/bash


for i in a b c d; do

        oc delete -f service-route-$i.yaml

done



