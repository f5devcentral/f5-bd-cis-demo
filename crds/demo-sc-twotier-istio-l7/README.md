# Overview

Creates a single-cluster L7 two-tier deployment where Istio is the in-cluster ingress controller. It is recommended to switch to the ocp3 cluster for this demo.

L7 routes created in Istio and in BIG-IP:

www.sc-istio.com/
www.sc-istio.com/shop
www.sc-istio.com/checkout
account.sc-istio.com/

The configuration in the BIG-IP will be in the sc-twotier partition

# Install and Run the demo

Run the script ./create-demo.sh which will:

- Install CIS and IPAM controller in the namespace cis-sc-twotier
- Create VirtualServices for Istio in the namespace sc-twotier
- Create VirtualServer resources in the istio-system namespace to expose Istio in BIG-IP

The L7 routes will be exposed in the BIG-IP using the IPAM controller, you should see something alike the next

```
[cloud-user@ocp-provisioner demo-sc-twotier-istio]$ oc -n istio-system get vs
NAME                    HOST               TLSPROFILENAME      HTTPTRAFFIC   IPADDRESS   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver-route-a   www.sc-istio.com   reencrypt-tls-www                             test        10.1.10.110     Ok       10m
virtualserver-route-b   www.sc-istio.com   reencrypt-tls-www                             test        10.1.10.110     Ok       10m
virtualserver-route-c   www.sc-istio.com   reencrypt-tls-www                             test        10.1.10.110     Ok       10m
virtualserver-route-d   account.sc-istio.com   reencrypt-tls-account                             test        10.1.10.110     Ok       10m
```

Edit the DNS and restart dnsmasq:

```
$ sudo vi /etc/dnsmasq.d/sc-istio.com.conf 
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


