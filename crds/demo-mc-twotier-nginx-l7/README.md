# Overview

Creates a multi-cluster L7 two-tier deployment with clusters ocp1, ocp2 and ocp3, where NGINX is in the second tier.

L7 routes created in NGINX and in BIG-IP:

```
www.mc-nginx.com/
www.mc-nginx.com/shop
www.mc-nginx.com/checkout
account.mc-nginx.com/
```

In the second tier (NGINX), these L7 routes are exposed with the Ingress resource type.

In the first tier (BIG-IP), these same L7 routes are exposed with the VirtualServer resource type. That is, there is a 1:1 mapping between the L7 routes in the first and second tier. There is one Service definition for each L7 route in the second tier, where the service definition is the same selecting always to the same Istio instances, but with diferent names for each Service. These duplicated Service definitions allow to have a separate pool for each L7 route and per service monitoring.

# Prerequisites

Install NGINX using the Operator´s Hub operator specifying manual update. Before deploying NGINX ingress controller apply the next kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-ingress-helm-operator/v2.1.0/resources/scc.yaml and using the UI create a NGINX ingress controller instance using the defaults.

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
- Create Ingress resources for NGINX in the namespace mc-twotier
- Create VirtualServer resources in the nginx-ingress namespace to expose NGINX in BIG-IP

The L7 routes will be exposed in both the NGINX controller and in the BIG-IP using the IPAM controller, you should see something alike the next respectively

```
$ export CLUSTER_LIST="ocp1 ocp2 ocp3"
$ run-clusters.sh oc -n mc-twotier get ingresses
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME                 CLASS   HOSTS                                   ADDRESS       PORTS     AGE
routes-www-account   nginx   www.mc-nginx.com,account.mc-nginx.com   10.1.10.241   80, 443   3m1s
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME                 CLASS   HOSTS                                   ADDRESS       PORTS     AGE
routes-www-account   nginx   www.mc-nginx.com,account.mc-nginx.com   10.1.10.243   80, 443   2m57s
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
NAME                 CLASS   HOSTS                                   ADDRESS       PORTS     AGE
routes-www-account   nginx   www.mc-nginx.com,account.mc-nginx.com   10.1.10.246   80, 443   2m54s
Switching back to initial context default/api-ocp3-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".

$ run-clusters.sh oc -n nginx-ingress get vs,svc
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME                                             HOST                   TLSPROFILENAME          HTTPTRAFFIC   IPADDRESS   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver.cis.f5.com/virtualserver-route-a   www.mc-nginx.com       reencrypt-tls-www                                 test        10.1.10.115     Ok       4m23s
virtualserver.cis.f5.com/virtualserver-route-b   www.mc-nginx.com       reencrypt-tls-www                                 test        10.1.10.115     Ok       4m22s
virtualserver.cis.f5.com/virtualserver-route-c   www.mc-nginx.com       reencrypt-tls-www                                 test        10.1.10.115     Ok       4m21s
virtualserver.cis.f5.com/virtualserver-route-d   account.mc-nginx.com   reencrypt-tls-account                             test        10.1.10.115     Ok       4m21s

NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/nginx-ingress-operator-controller-manager-metrics-service   ClusterIP      172.30.29.146    <none>        8443/TCP                     2d22h
service/nginxingress-sample-nginx-ingress-controller                LoadBalancer   172.30.159.241   10.1.10.241   80:32617/TCP,443:32079/TCP   2d22h
service/svc-route-a                                                 ClusterIP      172.30.146.240   <none>        443/TCP                      4m33s
service/svc-route-b                                                 ClusterIP      172.30.113.38    <none>        443/TCP                      4m32s
service/svc-route-c                                                 ClusterIP      172.30.108.182   <none>        443/TCP                      4m32s
service/svc-route-d                                                 ClusterIP      172.30.197.144   <none>        443/TCP                      4m31s
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME                                             HOST                   TLSPROFILENAME          HTTPTRAFFIC   IPADDRESS   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver.cis.f5.com/virtualserver-route-a   www.mc-nginx.com       reencrypt-tls-www                                 test                                 4m18s
virtualserver.cis.f5.com/virtualserver-route-b   www.mc-nginx.com       reencrypt-tls-www                                 test                                 4m18s
virtualserver.cis.f5.com/virtualserver-route-c   www.mc-nginx.com       reencrypt-tls-www                                 test                                 4m17s
virtualserver.cis.f5.com/virtualserver-route-d   account.mc-nginx.com   reencrypt-tls-account                             test                                 4m16s

NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/nginx-ingress-operator-controller-manager-metrics-service   ClusterIP      172.31.198.141   <none>        8443/TCP                     2d19h
service/nginxingress-sample-nginx-ingress-controller                LoadBalancer   172.31.226.95    10.1.10.243   80:30203/TCP,443:30130/TCP   2d19h
service/svc-route-a                                                 ClusterIP      172.31.136.212   <none>        443/TCP                      4m30s
service/svc-route-b                                                 ClusterIP      172.31.226.176   <none>        443/TCP                      4m29s
service/svc-route-c                                                 ClusterIP      172.31.141.72    <none>        443/TCP                      4m29s
service/svc-route-d                                                 ClusterIP      172.31.133.107   <none>        443/TCP                      4m28s
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
NAME                                                                TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/nginx-ingress-operator-controller-manager-metrics-service   ClusterIP      172.30.127.215   <none>        8443/TCP                     2d19h
service/nginxingress-sample-nginx-ingress-controller                LoadBalancer   172.30.83.79     10.1.10.246   80:32664/TCP,443:32753/TCP   2d19h
service/svc-route-a                                                 ClusterIP      172.30.210.26    <none>        443/TCP                      4m28s
service/svc-route-b                                                 ClusterIP      172.30.9.157     <none>        443/TCP                      4m28s
service/svc-route-c                                                 ClusterIP      172.30.33.168    <none>        443/TCP                      4m27s
service/svc-route-d                                                 ClusterIP      172.30.91.0      <none>        443/TCP                      4m26s
Switching back to initial context default/api-ocp3-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".

```

Edit the DNS to match the IP address in the BIG-IP (reported by the virtualserver resource). Next is an example when using dnsmasq:

```
$ sudo bash -c 'echo "address=/mc-nginx.com/10.1.10.115" > /etc/dnsmasq.d/mc-nginx.com.conf'
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


