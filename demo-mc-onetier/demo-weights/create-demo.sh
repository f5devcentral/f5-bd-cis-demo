#!/bin/bash


oc adm new-project --node-selector="" mc-onetier-eng-caas-nginx-app1

oc label ns mc-onetier-eng-caas-nginx-app1 router=bigip environment=test

oc create sa nginx -n mc-onetier-eng-caas-nginx-app1
oc adm policy add-scc-to-user privileged system:serviceaccount:mc-onetier-eng-caas-nginx-app1:nginx

oc apply -f configmap-nginx-app1.yaml

# Only create if not previously created
[ ! -r certs/nginx-app1.key ] && openssl req -x509 -nodes -days 365 -keyout certs/nginx-app1.key -out certs/nginx-app1.crt -config certs/nginx-app1.cfg

oc create secret tls nginx-app1 -n mc-onetier-eng-caas-nginx-app1 --key certs/nginx-app1.key --cert certs/nginx-app1.crt


oc apply -f nginx-v1.yaml
oc apply -f nginx-v2.yaml

oc apply -f nginx-test-v1.yaml
oc apply -f nginx-test-v2.yaml

oc apply -f nginx-alt-v1.yaml
oc apply -f nginx-alt-v2.yaml

oc apply -f nginx-route.yaml
oc apply -f nginx-route-test.yaml
oc apply -f nginx-alt-route.yaml


