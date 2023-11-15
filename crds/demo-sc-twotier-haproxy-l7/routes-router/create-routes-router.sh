#!/bin/bash

oc create ns sc-twotier
oc label ns sc-twotier router=shard-apps

for n in a b c d ; do
	oc apply -f route-$n.yaml
done


