# Overview

Creates a single-cluster L7 two-tier deployment where OpenShift's router (HA-proxy) is used in the second tier. A separate shard (see https://docs.openshift.com/container-platform/4.12/networking/ingress-sharding.html). This is useful, for instance, to separate resources for OpenShift´s own Routes and workload´s Routes.

L7 routes created in HA-proxy and in BIG-IP:

```
www.sc-twotier.com/
www.sc-twotier.com/shop
www.sc-twotier.com/checkout
account.sc-twotier.com/
```

In the second tier (HA-proxy), these L7 routes are exposed with the Route resource type.

In the first tier (BIG-IP), these same L7 routes are exposed with the VirtualServer resource type. That is, there is a 1:1 mapping between the L7 routes in the first and second tier. There is one Service definition for each L7 route in the second tier, where the service definition is the same selecting always to the same HA-proxy instances, but with diferent names for each Service. These duplicated Service definitions allow to have a separate pool for each L7 route and per service monitoring.

The L7 routes are exposed in both BIG-IP and HA-proxy as HTTPS only

# Install and Run the demo

Run the script ./create-demo.sh which will:

- Install CIS without IPAM controller in the namespace cis-sc-twotier
- Create Route resources for HA-proxy in the namespace sc-twotier
- Create VirtualServer resources in the openshift-ingress namespace to expose HA-proxy in BIG-IP

The L7 routes will be exposed in both the HA-proxy controller and in the BIG-IP, you should see something alike the next respectively

```
$ oc -n sc-twotier get route
NAME      HOST/PORT                PATH        SERVICES   PORT   TERMINATION   WILDCARD
route-a   www.sc-twotier.com       /           route-a    8080   edge          None
route-b   www.sc-twotier.com       /shop       route-b    8080   edge          None
route-c   www.sc-twotier.com       /checkout   route-c    8080   edge          None
route-d   account.sc-twotier.com   /           route-d    8080   edge          None

$ oc -n openshift-ingress get vs,svc
NAME                               HOST                     TLSPROFILENAME   HTTPTRAFFIC   IPADDRESS     IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
virtualserver.cis.f5.com/route-a   www.sc-twotier.com       reencrypt-tls                  10.1.10.104               10.1.10.104     Ok       14m
virtualserver.cis.f5.com/route-b   www.sc-twotier.com       reencrypt-tls                  10.1.10.104               10.1.10.104     Ok       14m
virtualserver.cis.f5.com/route-c   www.sc-twotier.com       reencrypt-tls                  10.1.10.104               10.1.10.104     Ok       14m
virtualserver.cis.f5.com/route-d   account.sc-twotier.com   reencrypt-tls                  10.1.10.104               10.1.10.104     Ok       14m

NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
service/router-internal-default      ClusterIP   172.30.158.83    <none>        80/TCP,443/TCP,1936/TCP   113d
service/router-internal-shard-apps   ClusterIP   172.30.161.29    <none>        80/TCP,443/TCP,1936/TCP   14m
service/router-shard-apps-route-a    ClusterIP   172.30.139.137   <none>        80/TCP,443/TCP            3m4s
service/router-shard-apps-route-b    ClusterIP   172.30.119.201   <none>        80/TCP,443/TCP            3m3s
service/router-shard-apps-route-c    ClusterIP   172.30.4.221     <none>        80/TCP,443/TCP            3m2s
service/router-shard-apps-route-d    ClusterIP   172.30.17.71     <none>        80/TCP,443/TCP            3m

```

Edit the DNS to match the IP address in the BIG-IP (reported by the virtualserver resource). Next is an example when using dnsmasq:

```
$ sudo bash -c 'echo "address=/sc-twotier.com/10.1.10.104" > /etc/dnsmasq.d/sc-twotier.com.conf'
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


