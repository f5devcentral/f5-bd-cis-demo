#!/bin/bash

use-cluster.sh ocp1

oc delete -f service-red.yaml
oc delete -f service-green.yaml
oc delete -f service-blue.yaml

oc delete -f tls-reencrypt-www.yaml
oc delete -f tls-reencrypt-shop.yaml

oc delete -f route-red.yaml
oc delete -f route-green.yaml
oc delete -f route-blue.yaml

use-cluster.sh ocp2

oc delete -f service-red.yaml
oc delete -f service-blue.yaml

oc delete -f tls-reencrypt-www.yaml
oc delete -f tls-reencrypt-shop.yaml

oc delete -f route-red.yaml
oc delete -f route-green.yaml
oc delete -f route-blue.yaml

use-cluster.sh ocp3

oc delete -f service-green.yaml
oc delete -f service-blue.yaml

