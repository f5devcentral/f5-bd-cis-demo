#!/bin/bash


oc apply -f eng-caas-guestbook-app1.ns.yaml

kubectl create -n mc-onetier-eng-caas-guestbook-app1 secret tls cafe-tls-secret \
  --cert=certs/Cafe-example.crt \
  --key=certs/Cafe-example.key

oc apply -f redis-app1.yaml
oc apply -f guestbook-app1.yaml

####

oc adm new-project --node-selector="" mc-onetier-eng-caas-nginx-app1

oc label ns mc-onetier-eng-caas-nginx-app1 router=bigip environment=test

oc create sa nginx -n mc-onetier-eng-caas-nginx-app1
oc adm policy add-scc-to-user privileged system:serviceaccount:mc-onetier-eng-caas-nginx-app1:nginx
 
oc apply -f configmap-nginx-app1.yaml
 
# Only create if not previously created
[ ! -r certs/nginx-app1.key ] && openssl req -x509 -nodes -days 365 -keyout certs/nginx-app1.key -out certs/nginx-app1.crt -config certs/nginx-app1.cfg

oc create secret tls nginx-app1 -n mc-onetier-eng-caas-nginx-app1 --key certs/nginx-app1.key --cert certs/nginx-app1.crt
 
oc apply -f nginx.yaml

