#!/bin/bash

for n in a b c d ; do
	oc create ns sc-twotier-shard-$n
	oc label ns sc-twotier-shard-$n router=shard-$n
	oc apply -f route-shard-$n.yaml
done


