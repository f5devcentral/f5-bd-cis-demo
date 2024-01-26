#!/bin/bash

set -x

watch -n 0.5 "curl -s -k https://www.mc-istio.com/ ;
curl -s -k https://www.mc-istio.com/shop ; 
curl -s -k https://www.mc-istio.com/checkout ; 
curl -s -k https://account.mc-istio.com/ "

