#!/bin/bash

CLUSTER_ALIAS=$1

use-cluster.sh $CLUSTER_ALIAS

oc delete ns mc-twotier


