#!/bin/bash

routefile=$1.yaml
weightblue=$2
weightgreen=$3

perl -i -p -e "s/^    weight:.*/    weight: $weightblue/" $routefile
perl -i -p -e "s/^      weight:.*/      weight: $weightgreen/" $routefile

run-clusters.sh oc apply -f $routefile

