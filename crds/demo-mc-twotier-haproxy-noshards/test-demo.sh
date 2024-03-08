#!/bin/bash

set -x

watch -n 0.5 "curl -s -k https://www.migration.com/ ;
curl -s -k https://www.migration.com/shop ; 
curl -s -k https://www.migration.com/checkout ; 
curl -s -k https://account.migration.com/ "

