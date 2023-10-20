#!/bin/bash

for n in a b c d ; do
	oc delete ns sc-twotier-shard-$n
done


