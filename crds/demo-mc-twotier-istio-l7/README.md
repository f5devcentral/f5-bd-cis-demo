# Overview

Creates a multi-cluster L7 two-tier deployment with clusters ocp1, ocp2 and ocp3, where Istio is in the second tier.

L7 routes created in Istio and in BIG-IP:

```
www.mc-istio.com/
www.mc-istio.com/shop
www.mc-istio.com/checkout
account.mc-istio.com/
```

In the second tier (Istio), these L7 routes are exposed with the VirtualService resource type.

In the first tier (BIG-IP), these same L7 routes are exposed with the VirtualServer resource type. That is, there is a 1:1 mapping between the L7 routes in the first and second tier. There is one Service definition for each L7 route in the second tier, where the service definition is the same selecting always to the same Istio instances, but with diferent names for each Service. These duplicated Service definitions allow to have a separate pool for each L7 route and per service monitoring.

# Prerequisites

Install Istio following OpenShift´s documentation.

It is needed to pre-create a server-side SSL profile with SNI for the following domains: www.mc-twotier.com and account.mc-twotier.com

It is needed to pre-create an HTTPs monitors using these server-side SSL profiles for the L7 above.

These configurations are shown next

```
ltm profile server-ssl www.mc-twotier.com {
    app-service none
    defaults-from serverssl
    server-name www.mc-twotier.com
    sni-default true
}
ltm profile server-ssl account.mc-twotier.com {
    app-service none
    defaults-from serverssl
    server-name account.mc-twotier.com
}
ltm monitor https www.mc-twotier.com {
    defaults-from https
    recv "^HTTP/1.1 200"
    send "GET / HTTP/1.1\r\nHost: www.mc-twotier.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.mc-twotier.com
}
ltm monitor https www.mc-twotier.com-shop {
    recv "^HTTP/1.1 200"
    send "GET /shop HTTP/1.1\r\nHost: www.mc-twotier.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.mc-twotier.com
}
ltm monitor https www.mc-twotier.com-checkout {
    recv "^HTTP/1.1 200"
    send "GET /checkout HTTP/1.1\r\nHost: www.mc-twotier.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.mc-twotier.com
}
ltm monitor https account.mc-twotier.com {
    recv "^HTTP/1.1 200"
    send "GET / HTTP/1.1\r\nHost: account.mc-twotier.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/account.mc-twotier.com
}
```

# Install and Run the demo

Run the script ./create-demo.sh which will:

- Install CIS and IPAM controller in the namespace cis-mc-twotier
- Create VirtualServices for Istio in the namespace mc-twotier
- Create VirtualServer resources in the istio-system namespace to expose Istio in BIG-IP

The L7 routes will be exposed in both the NGINX controller and in the BIG-IP using the IPAM controller, you should see something alike the next respectively

```
$ export CLUSTER_LIST="ocp1 ocp2 ocp3"
$ run-clusters.sh oc -n mc-twotier get virtualservice
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME               GATEWAYS       HOSTS                      AGE
mc-istio-account   ["mc-istio"]   ["account.mc-istio.com"]   128m
mc-istio-www       ["mc-istio"]   ["www.mc-istio.com"]       128m
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME               GATEWAYS       HOSTS                      AGE
mc-istio-account   ["mc-istio"]   ["account.mc-istio.com"]   128m
mc-istio-www       ["mc-istio"]   ["www.mc-istio.com"]       128m
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
NAME               GATEWAYS       HOSTS                      AGE
mc-istio-account   ["mc-istio"]   ["account.mc-istio.com"]   128m
mc-istio-www       ["mc-istio"]   ["www.mc-istio.com"]       128m
Switching back to initial context default/api-ocp3-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".

$ run-clusters.sh oc -n istio-system get vs,svc
[cloud-user@ocp-provisioner demo-mc-twotier-nginx-l7]$ run-clusters.sh oc -n istio-system get vs,svc
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME                                             HOST                   TLSPROFILENAME          HTTPTRAFFIC   IPADDRESS   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver.cis.f5.com/virtualserver-route-a   www.mc-istio.com       reencrypt-tls-www                                 test        10.1.10.111     Ok       128m
virtualserver.cis.f5.com/virtualserver-route-b   www.mc-istio.com       reencrypt-tls-www                                 test        10.1.10.111     Ok       128m
virtualserver.cis.f5.com/virtualserver-route-c   www.mc-istio.com       reencrypt-tls-www                                 test        10.1.10.111     Ok       128m
virtualserver.cis.f5.com/virtualserver-route-d   account.mc-istio.com   reencrypt-tls-account                             test        10.1.10.111     Ok       128m

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                              AGE
service/grafana                     ClusterIP   172.30.190.97    <none>        3000/TCP                                                             71d
service/istio-egressgateway         ClusterIP   172.30.176.241   <none>        80/TCP,443/TCP                                                       71d
service/istio-ingressgateway        ClusterIP   172.30.97.73     <none>        15021/TCP,80/TCP,443/TCP                                             71d
service/istiod-basic                ClusterIP   172.30.179.197   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP,8188/TCP                       71d
service/jaeger-agent                ClusterIP   None             <none>        5775/UDP,5778/TCP,6831/UDP,6832/UDP,14271/TCP                        71d
service/jaeger-collector            ClusterIP   172.30.174.233   <none>        9411/TCP,14250/TCP,14267/TCP,14268/TCP,14269/TCP,4317/TCP,4318/TCP   71d
service/jaeger-collector-headless   ClusterIP   None             <none>        9411/TCP,14250/TCP,14267/TCP,14268/TCP,14269/TCP,4317/TCP,4318/TCP   71d
service/jaeger-query                ClusterIP   172.30.48.87     <none>        443/TCP,16685/TCP,16687/TCP                                          71d
service/kiali                       ClusterIP   172.30.240.249   <none>        20001/TCP,9090/TCP                                                   71d
service/prometheus                  ClusterIP   172.30.112.28    <none>        9090/TCP                                                             71d
service/svc-route-a                 ClusterIP   172.30.113.157   <none>        8443/TCP                                                             129m
service/svc-route-b                 ClusterIP   172.30.96.244    <none>        8443/TCP                                                             129m
service/svc-route-c                 ClusterIP   172.30.201.172   <none>        8443/TCP                                                             129m
service/svc-route-d                 ClusterIP   172.30.16.76     <none>        8443/TCP                                                             129m
service/svc-route-wildcard          ClusterIP   172.30.128.70    <none>        8080/TCP,8443/TCP                                                    37d
service/zipkin                      ClusterIP   172.30.7.117     <none>        9411/TCP                                                             71d
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME                                             HOST                   TLSPROFILENAME          HTTPTRAFFIC   IPADDRESS   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver.cis.f5.com/virtualserver-route-a   www.mc-istio.com       reencrypt-tls-www                                 test                                 128m
virtualserver.cis.f5.com/virtualserver-route-b   www.mc-istio.com       reencrypt-tls-www                                 test                                 128m
virtualserver.cis.f5.com/virtualserver-route-c   www.mc-istio.com       reencrypt-tls-www                                 test                                 128m
virtualserver.cis.f5.com/virtualserver-route-d   account.mc-istio.com   reencrypt-tls-account                             test                                 128m

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                              AGE
service/grafana                     ClusterIP   172.31.46.238    <none>        3000/TCP                                                             71d
service/istio-egressgateway         ClusterIP   172.31.236.228   <none>        80/TCP,443/TCP                                                       71d
service/istio-ingressgateway        ClusterIP   172.31.78.42     <none>        15021/TCP,80/TCP,443/TCP                                             71d
service/istiod-basic                ClusterIP   172.31.245.43    <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP,8188/TCP                       71d
service/jaeger-agent                ClusterIP   None             <none>        5775/UDP,5778/TCP,6831/UDP,6832/UDP,14271/TCP                        71d
service/jaeger-collector            ClusterIP   172.31.133.45    <none>        9411/TCP,14250/TCP,14267/TCP,14268/TCP,14269/TCP,4317/TCP,4318/TCP   71d
service/jaeger-collector-headless   ClusterIP   None             <none>        9411/TCP,14250/TCP,14267/TCP,14268/TCP,14269/TCP,4317/TCP,4318/TCP   71d
service/jaeger-query                ClusterIP   172.31.8.210     <none>        443/TCP,16685/TCP,16687/TCP                                          71d
service/kiali                       ClusterIP   172.31.141.57    <none>        20001/TCP,9090/TCP                                                   71d
service/prometheus                  ClusterIP   172.31.69.64     <none>        9090/TCP                                                             71d
service/svc-route-a                 ClusterIP   172.31.155.225   <none>        8443/TCP                                                             129m
service/svc-route-b                 ClusterIP   172.31.2.26      <none>        8443/TCP                                                             129m
service/svc-route-c                 ClusterIP   172.31.130.207   <none>        8443/TCP                                                             129m
service/svc-route-d                 ClusterIP   172.31.173.255   <none>        8443/TCP                                                             129m
service/svc-route-wildcard          ClusterIP   172.31.85.19     <none>        8080/TCP,8443/TCP                                                    37d
service/zipkin                      ClusterIP   172.31.128.188   <none>        9411/TCP                                                             71d
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                              AGE
service/grafana                     ClusterIP   172.30.20.143    <none>        3000/TCP                                                             71d
service/istio-egressgateway         ClusterIP   172.30.62.81     <none>        80/TCP,443/TCP                                                       71d
service/istio-ingressgateway        ClusterIP   172.30.1.190     <none>        15021/TCP,80/TCP,443/TCP                                             71d
service/istiod-basic                ClusterIP   172.30.250.21    <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP,8188/TCP                       71d
service/jaeger-agent                ClusterIP   None             <none>        5775/UDP,5778/TCP,6831/UDP,6832/UDP,14271/TCP                        71d
service/jaeger-collector            ClusterIP   172.30.111.54    <none>        9411/TCP,14250/TCP,14267/TCP,14268/TCP,14269/TCP,4317/TCP,4318/TCP   71d
service/jaeger-collector-headless   ClusterIP   None             <none>        9411/TCP,14250/TCP,14267/TCP,14268/TCP,14269/TCP,4317/TCP,4318/TCP   71d
service/jaeger-query                ClusterIP   172.30.141.44    <none>        443/TCP,16685/TCP,16687/TCP                                          71d
service/kiali                       ClusterIP   172.30.166.66    <none>        20001/TCP,9090/TCP                                                   71d
service/prometheus                  ClusterIP   172.30.38.147    <none>        9090/TCP                                                             71d
service/svc-route-a                 ClusterIP   172.30.110.247   <none>        8443/TCP                                                             128m
service/svc-route-b                 ClusterIP   172.30.62.25     <none>        8443/TCP                                                             128m
service/svc-route-c                 ClusterIP   172.30.169.184   <none>        8443/TCP                                                             128m
service/svc-route-d                 ClusterIP   172.30.122.180   <none>        8443/TCP                                                             128m
service/zipkin                      ClusterIP   172.30.62.22     <none>        9411/TCP                                                             71d
Switching back to initial context default/api-ocp3-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".

```

Edit the DNS to match the IP address in the BIG-IP (reported by the virtualserver resource). Next is an example when using dnsmasq:

```
$ sudo bash -c 'echo "address=/mc-istio.com/10.1.10.111" > /etc/dnsmasq.d/mc-istio.com.conf'
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


