#!/bin/bash

oc create ns sc-twotier

for n in a b c d ; do
	oc apply -f route-$n.yaml
done


