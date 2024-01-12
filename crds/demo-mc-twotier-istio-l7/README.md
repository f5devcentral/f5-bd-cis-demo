# Overview

Creates a multi-cluster L7 two-tier deployment with clusters ocp1, ocp2 and ocp3, where Istio is in the second tier.

L7 routes created in Istio and in BIG-IP:

```
www.mc-istio.com/
www.mc-istio.com/shop
www.mc-istio.com/checkout
account.mc-istio.com/
```

In the second tier these virtualservice resources to expose the above L7 routes are in all clusters:
```
[cloud-user@ocp-provisioner routes-istio]$ run-clusters.sh oc -n mc-istio get virtualservice
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME               GATEWAYS       HOSTS                      AGE
mc-istio-account   ["mc-istio"]   ["account.mc-istio.com"]   38s
mc-istio-www       ["mc-istio"]   ["www.mc-istio.com"]       39s
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME               GATEWAYS       HOSTS                      AGE
mc-istio-account   ["mc-istio"]   ["account.mc-istio.com"]   12m
mc-istio-www       ["mc-istio"]   ["www.mc-istio.com"]       12m
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
NAME               GATEWAYS       HOSTS                      AGE
mc-istio-account   ["mc-istio"]   ["account.mc-istio.com"]   26s
mc-istio-www       ["mc-istio"]   ["www.mc-istio.com"]       26s
Switching back to initial context default/api-ocp2-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
```

In the first tier, there is a 1:1 mapping between the L7 routes in the second tier (Istio) and a Service pointing to Istio for each L7 route:




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
virtualserver-route-d   account.mc-istio.com   reencrypt-tls-account                             test        10.1.10.110     Ok       10m
```

Edit the DNS and restart dnsmasq:

```
$ sudo vi /etc/dnsmasq.d/mc-istio.com.conf 
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


