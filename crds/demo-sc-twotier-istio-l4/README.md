# Overview

Creates a L4 two-tier deployment where Istio is the in-cluster ingress controller.

L7 routes created in Istio, and these will mapped to the following VS in the BIG-IP:

```
www.sc-istio.com/         -> <IPAM address>:443
www.sc-istio.com/shop     -> <IPAM address>:443
www.sc-istio.com/checkout -> <IPAM address>:443
account.sc-istio.com/     -> <IPAM address>:8443
```

The configuration in the BIG-IP will be in the sc-twotier partition

# Install and Run the demo

Run the script ./create-demo.sh which will:

- Install CIS and IPAM controller in the namespace cis-sc-twotier
- Create VirtualServices for Istio in the namespace sc-twotier
- Create TransportServer resources in the istio-system namespace to expose Istio in BIG-IP

Istio will be exposed in the BIG-IP using the IPAM controller, you should see something alike the next

```
[cloud-user@ocp-provisioner demo-sc-twotier-istio-l4]$ oc -n istio-system get ts
NAME                      VIRTUALSERVERADDRESS   VIRTUALSERVERPORT   POOL                           POOLPORT   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
transportserver-account                          8443                istio-ingressgateway-account   8443       test        10.1.10.110     Ok       20s
transportserver-www                              443                 istio-ingressgateway-www       8443       test        10.1.10.110     Ok       21s
```

Edit the DNS and restart dnsmasq:

```
$ sudo vi /etc/dnsmasq.d/sc-istio.com.conf 
$ sudo systemctl restart dnsmasq
```

Run the ./test-demo.sh to verify that it works as expected, you should see something alike the next output:

```
$ ./test-demo.sh
+ curl -k https://www.sc-istio.com/
Two tier route A: www.sc-istio.com/
+ curl -k https://www.sc-istio.com/shop
Two tier Route B: www.sc-stio.com/shop
+ curl -k https://www.sc-istio.com/checkout
Two tier Route C: www.sc-istio.com/checkout
+ curl -k https://account.sc-istio.com:8443/
Two tier Route D: account.sc-istio.com/
```

# Delete the demo

Run the script ./delete-demo.sh

