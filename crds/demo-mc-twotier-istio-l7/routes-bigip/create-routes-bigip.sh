#!/bin/bash

oc apply -f reencrypt-tls-www.yaml
oc apply -f reencrypt-tls-account.yaml


for i in a b c ; do

        oc apply -f virtualserver-route-$i.yaml

done


