#!/bin/bash


for i in a b c ; do

        oc delete -f virtualserver-route-$i.yaml

done

oc delete -f reencrypt-tls-www.yaml
oc delete -f reencrypt-tls-account.yaml


