#!/bin/bash

oc delete -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/master/docs/config_examples/customResourceDefinitions/incubator/customresourcedefinitions.yml
oc delete ns cis-sc-twotier


