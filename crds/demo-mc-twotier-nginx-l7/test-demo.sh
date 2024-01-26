#!/bin/bash

set -x

watch -n 0.5 "curl -k -s https://www.mc-nginx.com/ ;
curl -k -s https://www.mc-nginx.com/shop ; 
curl -k -s https://www.mc-nginx.com/checkout ; 
curl -k -s https://account.mc-nginx.com/ "

