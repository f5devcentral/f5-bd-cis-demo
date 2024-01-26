# Overview

Creates a single-cluster L7 two-tier deployment where HA-proxy is in the second tier in 4 shards

L7 routes created in HA-proxy and in BIG-IP:

```
www.sharded.com/
www.sharded.com/shop
www.sharded.com/checkout
account.sharded.com/
```

In both the first tier (BIG-IP) and in the second tier (HA-proxy), these routes are exposed using the Route resource. That is, there is a 1:1 mapping between the L7 routes in the first and second tier. There is one Service definition for each L7 route in the second tier.

This demo is an extreme case of using sharding (see https://docs.openshift.com/container-platform/4.12/networking/ingress-sharding.html) where each route will be sent to a different shard:

```
www.sharded.com/ ------------> HA proxy shard A --------> workload
www.sharded.com/shop --------> HA proxy shard B --------> workload
www.sharded.com/checkout ----> HA proxy shard C --------> workload
account.sharded.com/ --------> HA proxy shard D --------> workload
```

In order that the default HA-proxy doesn´t ingest the Route resources for the BIG-IP and other HA-proxy shards the following configuration is applied in the default IngressController manifest:


```
oc -n openshift-ingress-operator get ingresscontroller default -o yaml
[...]
  namespaceSelector:
    matchExpressions:
    - key: router
      operator: NotIn
      values:
      - shard-a
      - shard-b
      - shard-c
      - shard-d
      - bigip
```

where the Routes in namespace with label router=bigip or shard-x

The new shards have namespaceSelector configuration as follows:

```
  namespaceSelector:
    matchExpressions:
    - key: router
      operator: In
      values:
      - shard-a
```

For more details on the route sharding configuration, check the create-shards.sh script.

# Prerequisites

Run the create-shards.sh script and wait for several minutes until all the shards are READY and AVAILABLE. To undo these Router shard changes use the delete-shards.sh script.

Modify the files 

```
cis-config/global-cm.bigip1.yaml
cis-config/global-cm.bigip2.yaml
```
to specify the desired IP address for the virtual server

# Install and Run the demo

Run the script ./create-demo.sh which will:

- Install CIS in the namespace cis-sc-twotier
- Create the Routes for HA-proxy in the namespaces sc-twotier-shard-a ... sc-twotier-shard-d, one per shard
- Create the Routes for BIG-IP in the namespace openshift-ingress 

The overall is show next. Notice that the shards are configured to use Cluster IPs instead of HostNetwork IPs.

```
[cloud-user@ocp-provisioner demo-sc-twotier]$ oc -n openshift-ingress get route,svc,ep
NAME                               HOST/PORT             PATH        SERVICES                  PORT   TERMINATION   WILDCARD
route.route.openshift.io/shard-a   www.sharded.com       /           router-internal-shard-a   80     edge          None
route.route.openshift.io/shard-b   www.sharded.com       /shop       router-internal-shard-b   80     edge          None
route.route.openshift.io/shard-c   www.sharded.com       /checkout   router-internal-shard-c   80     edge          None
route.route.openshift.io/shard-d   account.sharded.com   /           router-internal-shard-d   80     edge          None

NAME                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
service/router-internal-default   ClusterIP   172.30.158.83    <none>        80/TCP,443/TCP,1936/TCP   115d
service/router-internal-shard-a   ClusterIP   172.30.179.34    <none>        80/TCP,443/TCP,1936/TCP   10m
service/router-internal-shard-b   ClusterIP   172.30.193.196   <none>        80/TCP,443/TCP,1936/TCP   10m
service/router-internal-shard-c   ClusterIP   172.30.250.91    <none>        80/TCP,443/TCP,1936/TCP   10m
service/router-internal-shard-d   ClusterIP   172.30.232.87    <none>        80/TCP,443/TCP,1936/TCP   10m

NAME                                ENDPOINTS                                            AGE
endpoints/router-internal-default   10.1.10.9:1936,10.1.10.9:443,10.1.10.9:80            115d
endpoints/router-internal-shard-a   10.130.5.190:1936,10.130.5.190:443,10.130.5.190:80   10m
endpoints/router-internal-shard-b   10.130.5.191:1936,10.130.5.191:443,10.130.5.191:80   10m
endpoints/router-internal-shard-c   10.130.5.192:1936,10.130.5.192:443,10.130.5.192:80   10m
endpoints/router-internal-shard-d   10.130.5.193:1936,10.130.5.193:443,10.130.5.193:80   10m
$ for shard in a b c d ; do oc -n sc-twotier-shard-$shard get route; done
NAME      HOST/PORT         PATH   SERVICES   PORT   TERMINATION   WILDCARD
shard-a   www.sharded.com   /      shard-a    8080                 None
NAME      HOST/PORT         PATH    SERVICES   PORT   TERMINATION   WILDCARD
shard-b   www.sharded.com   /shop   shard-b    8080                 None
NAME      HOST/PORT         PATH        SERVICES   PORT   TERMINATION   WILDCARD
shard-c   www.sharded.com   /checkout   shard-c    8080                 None
NAME      HOST/PORT             PATH   SERVICES   PORT   TERMINATION   WILDCARD
shard-d   account.sharded.com   /      shard-d    8080                 None
```

Edit the DNS to match the IP address in the BIG-IP (reported by the virtualserver resource). Next is an example when using dnsmasq:

```
$ sudo bash -c 'echo "address=/sharded.com/10.1.10.103" > /etc/dnsmasq.d/sharded.com.conf'
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


