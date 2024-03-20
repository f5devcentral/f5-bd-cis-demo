#!/bin/bash

helm -n cis-sc-twotier uninstall f5-ipam-controller

oc delete -f ipam-pvc.yaml
oc delete -f ipam-pv.yaml


