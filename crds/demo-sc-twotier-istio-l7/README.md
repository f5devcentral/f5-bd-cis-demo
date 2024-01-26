# Overview

Creates a single-cluster L7 two-tier deployment where Istio is used in the second tier. 

L7 routes created in Istio and in BIG-IP:

```
www.sc-istio.com/
www.sc-istio.com/shop
www.sc-istio.com/checkout
account.sc-istio.com/
```

In the second tier (Istio), these L7 routes are exposed with the VirtualService resource type.

In the first tier (BIG-IP), these same L7 routes are exposed with the VirtualServer resource type. That is, there is a 1:1 mapping between the L7 routes in the first and second tier. There is one Service definition for each L7 route in the second tier, where the service definition is the same selecting always to the same Istio instances, but with diferent names for each Service. These duplicated Service definitions allow to have a separate pool for each L7 route and per service monitoring.

The L7 routes are exposed in both BIG-IP and Istio as HTTPS only

The configuration in the BIG-IP will be in the sc-twotier partition

# Prerequites

It is needed to pre-create a server-side SSL profile with SNI for the following domains: www.sc-istio.com and account.sc-istio.com

It is needed to pre-create an HTTPs monitors using these server-side SSL profiles for the L7 above.

These configurations are shown next

```
ltm profile server-ssl www.sc-istio.com {
    app-service none
    defaults-from serverssl
    server-name www.sc-istio.com
    sni-default true
}
ltm profile server-ssl account.sc-istio.com {
    app-service none
    defaults-from serverssl
    server-name account.sc-istio.com
}
ltm monitor https www.sc-istio.com {
    defaults-from https
    recv "^HTTP/1.1 200"
    send "GET / HTTP/1.1\r\nHost: www.sc-istio.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.sc-istio.com
}
ltm monitor https www.sc-istio.com-shop {
    recv "^HTTP/1.1 200"
    send "GET /shop HTTP/1.1\r\nHost: www.sc-istio.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.sc-istio.com
}
ltm monitor https www.sc-istio.com-checkout {
    recv "^HTTP/1.1 200"
    send "GET /checkout HTTP/1.1\r\nHost: www.sc-istio.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.sc-istio.com
}
ltm monitor https account.sc-istio.com {
    recv "^HTTP/1.1 200"
    send "GET / HTTP/1.1\r\nHost: account.sc-istio.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/account.sc-istio.com
}
```

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
$ sudo bash -c 'echo "address=/sc-istio.com/10.1.10.110" > /etc/dnsmasq.d/sc-istio.com.conf'
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


