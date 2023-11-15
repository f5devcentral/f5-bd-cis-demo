#!/bin/bash

set -x

watch -n 0.5 "curl -s https://www.mc-sharded.com/ ;
curl -s https://www.mc-sharded.com/shop ; 
curl -s https://www.mc-sharded.com/checkout ; 
curl -s https://account.mc-sharded.com/ "

