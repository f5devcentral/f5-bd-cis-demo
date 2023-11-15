#!/bin/bash

helm install -n cis-sc-twotier -f values.yaml f5-ipam-controller f5-ipam-controller-0.0.4.tgz 

