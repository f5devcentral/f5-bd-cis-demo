#!/bin/bash

use-cluster.sh ocp1

oc apply -f service-red.yaml
oc apply -f service-green.yaml
oc apply -f service-blue.yaml

oc apply -f tls-reencrypt-www.yaml
oc apply -f tls-reencrypt-shop.yaml

oc apply -f route-red.yaml
oc apply -f route-green.yaml
oc apply -f route-blue.yaml

use-cluster.sh ocp2

oc apply -f service-red.yaml
oc apply -f service-blue.yaml

oc apply -f tls-reencrypt-www.yaml
oc apply -f tls-reencrypt-shop.yaml

oc apply -f route-red.yaml
oc apply -f route-green.yaml
oc apply -f route-blue.yaml

use-cluster.sh ocp3

oc apply -f service-green.yaml
oc apply -f service-blue.yaml

