#!/bin/bash

set -x

watch -n 0.5 "curl -s https://www.mc-istio.com/ ;
curl -s https://www.mc-istio.com/shop ; 
curl -s https://www.mc-istio.com/checkout ; 
curl -s https://account.mc-istio.com/ "

