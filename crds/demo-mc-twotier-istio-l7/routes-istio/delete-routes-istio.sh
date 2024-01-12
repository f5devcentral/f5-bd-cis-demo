#!/bin/bash

kubectl delete -n istio-system secret mc-istio-credential
oc delete ns mc-istio


