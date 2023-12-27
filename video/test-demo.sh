#!/bin/bash

set -x

watch -n 5 "curl -s https://www.multicluster.com/ ;
curl -s https://www.multicluster.com/account ; 
curl -s https://shop.multicluster.com/ "

