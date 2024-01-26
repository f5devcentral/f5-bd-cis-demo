#!/bin/bash

set -x

watch -n 0.5 "curl -s -k https://www.mc-sharded.com/ ;
curl -s -k https://www.mc-sharded.com/shop ; 
curl -s -k https://www.mc-sharded.com/checkout ; 
curl -s -k https://account.mc-sharded.com/ "

