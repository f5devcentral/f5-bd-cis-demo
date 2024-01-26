# Overview

Creates a L4 two-tier deployment where Istio is the second tier.

The L7 routes created in Istio are the following:

```
www.sc-istio.com/
www.sc-istio.com/shop
www.sc-istio.com/checkout
account.sc-istio.com/
```

These will be mapped into the following L4 TransportServers in the BIG-IP

All L7 routes of FQDN www.sc-istio.com will be mapped in Transport server https://www.sc-istio.com
The L7 route account.sc-istio.com will be mapped in the Transport server https://account.sc-istio.com:8443 (note the difference in port)

Where www.sc-istio.com an account.sc-istio.com will use a dynamically allocated addresses using the F5 IPAM controller and both FQDNs will be sharing the same IP address (because of the use of hostGroups).

The configuration in the BIG-IP will be in the sc-twotier partition

# Prerequisites

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
$ sudo bash -c 'echo "address=/sc-istio.com/10.1.10.110" > /etc/dnsmasq.d/sc-istio.com.conf'
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

