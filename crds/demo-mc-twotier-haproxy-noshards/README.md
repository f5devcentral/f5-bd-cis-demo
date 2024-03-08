# Overview

This example has been created for the DevCentral article [F5 BIG-IP per application Red Hat OpenShift cluster migrations](https://community.f5.com/kb/technicalarticles/f5-big-ip-per-application-red-hat-openshift-cluster-migrations/328268)

It creates a multi-cluster L7 two-tier deployment with clusters ocp1 and ocp2, where HA-proxy is in the second tier.

L7 routes created in HA-proxy and in BIG-IP:

```
www.migration.com/
www.migration.com/shop
www.migration.com/checkout
account.migration.com/
```

In the second tier (HA-proxy), these L7 routes are exposed with the Route resource type.

In the first tier (BIG-IP), these same L7 routes are exposed with the VirtualServer resource type. That is, there is a 1:1 mapping between the L7 routes in the first and second tier. There is one Service definition for each L7 route in the second tier, where the service definition is the same selecting always to the same Istio instances, but with diferent names for each Service. These duplicated Service definitions allow to have a separate pool for each L7 route and per service monitoring.

# Prerequisites

It is needed to pre-create a server-side SSL profile with SNI for the following domains: www.migration.com and account.migration.com

It is needed to pre-create an HTTPs monitors using these server-side SSL profiles for the L7 above.

These configurations are shown next

```
ltm profile server-ssl www.migration.com {
    app-service none
    defaults-from serverssl
    server-name www.migration.com
    sni-default true
}
ltm profile server-ssl account.migration.com {
    app-service none
    defaults-from serverssl
    server-name account.migration.com
}
ltm monitor https www.migration.com {
    defaults-from https
    recv "^HTTP/1.1 200"
    send "GET / HTTP/1.1\r\nHost: www.migration.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.migration.com
}
ltm monitor https www.migration.com-shop {
    recv "^HTTP/1.1 200"
    send "GET /shop HTTP/1.1\r\nHost: www.migration.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.migration.com
}
ltm monitor https www.migration.com-checkout {
    recv "^HTTP/1.1 200"
    send "GET /checkout HTTP/1.1\r\nHost: www.migration.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/www.migration.com
}
ltm monitor https account.migration.com {
    recv "^HTTP/1.1 200"
    send "GET / HTTP/1.1\r\nHost: account.migration.com\r\nConnection: close\r\n\r\n"
    ssl-profile /Common/account.migration.com
}
```

# Install and Run the demo

Run the script ./create-demo.sh which will:

- Install CIS controller in the namespace cis-mc-twotier
- Create VirtualServer resources in the nginx-ingress namespace to expose NGINX in BIG-IP

The L7 routes will be exposed in both the in the BIG-IP and HA-proxy respectively, you should see something alike the next respectively

```
$ export CLUSTER_LIST="ocp1 ocp2"
$ run-clusters.sh oc -n openshift-ingress get vs,svc
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME                               HOST                    TLSPROFILENAME   HTTPTRAFFIC   IPADDRESS     IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver.cis.f5.com/route-a   www.migration.com       reencrypt-tls                  10.1.10.106               10.1.10.106     Ok       15d
virtualserver.cis.f5.com/route-b   www.migration.com       reencrypt-tls                  10.1.10.106               10.1.10.106     Ok       15d
virtualserver.cis.f5.com/route-c   www.migration.com       reencrypt-tls                  10.1.10.106               10.1.10.106     Ok       15d
virtualserver.cis.f5.com/route-d   account.migration.com   reencrypt-tls                  10.1.10.106               10.1.10.106     Ok       10d

NAME                                  TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/router-default-route-a-ocp1   NodePort       172.30.112.172   <none>        80:32513/TCP,443:32225/TCP   15d
service/router-default-route-b-ocp1   NodePort       172.30.85.73     <none>        80:30201/TCP,443:31693/TCP   15d
service/router-default-route-c-ocp1   NodePort       172.30.27.180    <none>        80:30347/TCP,443:31899/TCP   15d
service/router-default-route-d-ocp1   NodePort       172.30.30.19     <none>        80:30371/TCP,443:31611/TCP   15d
service/router-internal-default       ClusterIP      172.30.76.194    <none>        80/TCP,443/TCP,1936/TCP      245d
service/service-lb-haproxy            LoadBalancer   172.30.40.112    10.1.10.240   80:31914/TCP,443:30045/TCP   51d
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME                               HOST                    TLSPROFILENAME   HTTPTRAFFIC   IPADDRESS     IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver.cis.f5.com/route-a   www.migration.com       reencrypt-tls                  10.1.10.106               10.1.10.106     Ok       15d
virtualserver.cis.f5.com/route-b   www.migration.com       reencrypt-tls                  10.1.10.106               10.1.10.106     Ok       15d
virtualserver.cis.f5.com/route-c   www.migration.com       reencrypt-tls                  10.1.10.106               10.1.10.106     Ok       15d
virtualserver.cis.f5.com/route-d   account.migration.com   reencrypt-tls                  10.1.10.106               10.1.10.106     Ok       10d

NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/router-default-route-a-ocp2   NodePort    172.31.48.29     <none>        80:30204/TCP,443:31125/TCP   15d
service/router-default-route-b-ocp2   NodePort    172.31.41.76     <none>        80:30422/TCP,443:31745/TCP   15d
service/router-default-route-c-ocp2   NodePort    172.31.210.159   <none>        80:31985/TCP,443:30072/TCP   15d
service/router-default-route-d-ocp2   NodePort    172.31.124.62    <none>        80:32763/TCP,443:32624/TCP   15d
service/router-internal-default       ClusterIP   172.31.242.67    <none>        80/TCP,443/TCP,1936/TCP      245d
Switching back to initial context default/api-ocp2-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".

$ run-clusters.sh oc -n mc-twotier get route,deployment
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME                               HOST/PORT               PATH        SERVICES   PORT   TERMINATION   WILDCARD
route.route.openshift.io/route-a   www.migration.com       /           route-a    8080   edge          None
route.route.openshift.io/route-b   www.migration.com       /shop       route-b    8080   edge          None
route.route.openshift.io/route-c   www.migration.com       /checkout   route-c    8080   edge          None
route.route.openshift.io/route-d   account.migration.com   /           route-d    8080   edge          None

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/route-a   3/3     3            3           10d
deployment.apps/route-b   3/3     3            3           10d
deployment.apps/route-c   3/3     3            3           10d
deployment.apps/route-d   3/3     3            3           10d
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME                               HOST/PORT               PATH        SERVICES   PORT   TERMINATION   WILDCARD
route.route.openshift.io/route-a   www.migration.com       /           route-a    8080   edge          None
route.route.openshift.io/route-b   www.migration.com       /shop       route-b    8080   edge          None
route.route.openshift.io/route-c   www.migration.com       /checkout   route-c    8080   edge          None
route.route.openshift.io/route-d   account.migration.com   /           route-d    8080   edge          None

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/route-a   3/3     3            3           10d
deployment.apps/route-b   3/3     3            3           10d
deployment.apps/route-c   3/3     3            3           10d
deployment.apps/route-d   3/3     3            3           10d
Switching back to initial context default/api-ocp2-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
```

Edit the DNS to match the IP address in the virtualserver resources. Next is an example when using dnsmasq:

```
$ sudo bash -c 'echo "address=/migration.com/10.1.10.106" > /etc/dnsmasq.d/migration.com.conf'
$ sudo systemctl restart dnsmasq
```

# Delete the demo

Run the script ./delete-demo.sh


