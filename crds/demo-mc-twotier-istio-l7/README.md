# Overview

Creates a multi-cluster L7 two-tier deployment with clusters ocp1 and ocp2, where Istio is the in-cluster ingress controller.

L7 routes created in Istio and in BIG-IP:

www.mc-istio.com/
www.mc-istio.com/shop
www.mc-istio.com/checkout
account.sc-istio.com/

At time of this writing I had a problem with account.mc-istio.com, not sure if it is a problem of my config but I reported in https://github.com/F5Networks/k8s-bigip-ctlr/issues/3145

The configuration in the BIG-IP will be in the mc-twotier partition

# Install and Run the demo

Run the script ./create-demo.sh which will:

- Install CIS and IPAM controller in the namespace cis-mc-twotier
- Create VirtualServices for Istio in the namespace mc-twotier
- Create VirtualServer resources in the istio-system namespace to expose Istio in BIG-IP

The L7 routes will be exposed in the BIG-IP using the IPAM controller, you should see something alike the next

```
[cloud-user@ocp-provisioner demo-sc-twotier-istio]$ oc -n istio-system get vs
NAME                    HOST               TLSPROFILENAME      HTTPTRAFFIC   IPADDRESS   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver-route-a   www.mc-istio.com   reencrypt-tls-www                             test        10.1.10.110     Ok       10m
virtualserver-route-b   www.mc-istio.com   reencrypt-tls-www                             test        10.1.10.110     Ok       10m
virtualserver-route-c   www.mc-istio.com   reencrypt-tls-www                             test        10.1.10.110     Ok       10m
```

Edit the DNS and restart dnsmasq:

```
$ sudo vi /etc/dnsmasq.d/mc-istio.com.conf 
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


