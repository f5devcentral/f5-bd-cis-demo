# Overview

Creates a multi-cluster L7 two-tier deployment with clusters ocp1, ocp2 and ocp3, where HA-proxy is in the second tier.

L7 routes created in HA-proxy and in BIG-IP:

```
www.mc-sharded.com/
www.mc-sharded.com/shop
www.mc-sharded.com/checkout
account.mc-sharded.com/
```

That is, there is a 1:1 mapping between the L7 routes in the first and second tier. There is one Service definition for each L7 route in the second tier, where the service definition is the same selecting alwaysto the same HA-proxy instances, but with diferent names for each Service. These duplicated Service definitions allow to have a separate pool for each L7 route and per service monitoring.

In both the first tier (BIG-IP) and in the second tier (HA-proxy), these routes are exposed using the Route resource. 

In order that the default HA-proxy doesn´t ingest the Route resources for the BIG-IP the following configuration is applied in the default IngressController manifest:

```
{
    "spec": {
        "namespaceSelector": {
            "matchExpressions": [
                {
                    "key": "router",
                    "operator": "NotIn",
                    "values": [
			"bigip"
                    ]
                }
            ]
        }
     }
}
```

where the Routes in namespace with label router=bigip will not be ingested by the default HA-proxy instance.

In this demo it is created an additional Router shard (see https://docs.openshift.com/container-platform/4.12/networking/ingress-sharding.html). This is in practice an additional Router instance that will only ingest the Routes in namespaces with label router=mc-shard. Creating this additional shard allows to have a dedicated Router instance for the OpenShift cluster Routes and a dedicated Router instance for the workloads. 

Overall the IngressController manifest of the default router is as follows:

```
{
    "spec": {
        "namespaceSelector": {
            "matchExpressions": [
                {
                    "key": "router",
                    "operator": "NotIn",
                    "values": [
			"mc-shard",
			"bigip"
                    ]
                }
            ]
        }
     }
}
```

and the new IngressController mc-shard is created as follows to only watch the namespaces with label:

```
  namespaceSelector:
    matchExpressions:
    - key: router
      operator: In
      values:
      - mc-shard
```

For more details on route sharding, check the create-shards.sh script.

# Prerequisites

Run the create-shards.sh script and wait for several minutes until both the default and mc-shard are READY and AVAILABLE. To undo these Router shard changes use the delete-shards.sh script.

Modify the files 

```
cis-config/global-cm.bigip1.yaml
cis-config/global-cm.bigip2.yaml
```
to specify the desired IP address for the virtual server

# Install and Run the demo

Run the script ./create-demo.sh which will:

- Install CIS in the namespace cis-mc-twotier
- Create the Routes for HA-proxy in the namespace mc-twotier-shard-mc. Not all services will be available in all clusters by default
- Create the Routes for BIG-IP in the namespace openshift-ingress 

```
$ export CLUSTER_LIST="ocp1 ocp2 ocp3"
$ run-clusters.sh oc -n mc-twotier-shard-mc get route,svc
[cloud-user@ocp-provisioner demo-mc-twotier]$ run-clusters.sh oc -n mc-twotier-shard-mc get route,svc
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME                                  HOST/PORT            PATH    SERVICES     PORT   TERMINATION   WILDCARD
route.route.openshift.io/mc-shard-a   www.mc-sharded.com   /       mc-shard-a   8080                 None
route.route.openshift.io/mc-shard-b   www.mc-sharded.com   /shop   mc-shard-b   8080                 None

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/mc-shard-a   ClusterIP   172.30.121.175   <none>        8080/TCP   67m
service/mc-shard-b   ClusterIP   172.30.88.90     <none>        8080/TCP   67m
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME                                  HOST/PORT            PATH        SERVICES     PORT   TERMINATION   WILDCARD
route.route.openshift.io/mc-shard-a   www.mc-sharded.com   /           mc-shard-a   8080                 None
route.route.openshift.io/mc-shard-c   www.mc-sharded.com   /checkout   mc-shard-c   8080                 None

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/mc-shard-a   ClusterIP   172.31.103.234   <none>        8080/TCP   67m
service/mc-shard-c   ClusterIP   172.31.105.215   <none>        8080/TCP   67m
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
NAME                                  HOST/PORT                PATH        SERVICES     PORT   TERMINATION   WILDCARD
route.route.openshift.io/mc-shard-a   www.mc-sharded.com       /           mc-shard-a   8080                 None
route.route.openshift.io/mc-shard-c   www.mc-sharded.com       /checkout   mc-shard-c   8080                 None
route.route.openshift.io/mc-shard-d   account.mc-sharded.com   /           mc-shard-d   8080                 None

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/mc-shard-a   ClusterIP   172.30.252.31   <none>        8080/TCP   67m
service/mc-shard-c   ClusterIP   172.30.74.135   <none>        8080/TCP   67m
service/mc-shard-d   ClusterIP   172.30.171.17   <none>        8080/TCP   66m

$ run-clusters.sh oc -n openshift-ingress get route,svc
[cloud-user@ocp-provisioner demo-mc-twotier]$ run-clusters.sh oc -n openshift-ingress get route,svc
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME                                  HOST/PORT                PATH        SERVICES                     PORT   TERMINATION   WILDCARD
route.route.openshift.io/mc-shard-a   www.mc-sharded.com       /           router-internal-mc-shard-a   80     edge          None
route.route.openshift.io/mc-shard-b   www.mc-sharded.com       /shop       router-internal-mc-shard-b   80     edge          None
route.route.openshift.io/mc-shard-c   www.mc-sharded.com       /checkout   router-internal-mc-shard-c   80     edge          None
route.route.openshift.io/mc-shard-d   account.mc-sharded.com   /           router-internal-mc-shard-d   80     edge          None

NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/router-internal-default      ClusterIP      172.30.76.194    <none>        80/TCP,443/TCP,1936/TCP      203d
service/router-internal-mc-shard     ClusterIP      172.30.46.27     <none>        80/TCP,443/TCP,1936/TCP      6h6m
service/router-internal-mc-shard-a   ClusterIP      172.30.105.157   <none>        80/TCP,443/TCP               53m
service/router-internal-mc-shard-b   ClusterIP      172.30.219.252   <none>        80/TCP,443/TCP               53m
service/service-lb-haproxy           LoadBalancer   172.30.40.112    10.1.10.240   80:31914/TCP,443:30045/TCP   9d
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME                                  HOST/PORT                PATH        SERVICES                     PORT   TERMINATION   WILDCARD
route.route.openshift.io/mc-shard-a   www.mc-sharded.com       /           router-internal-mc-shard-a   80     edge          None
route.route.openshift.io/mc-shard-b   www.mc-sharded.com       /shop       router-internal-mc-shard-b   80     edge          None
route.route.openshift.io/mc-shard-c   www.mc-sharded.com       /checkout   router-internal-mc-shard-c   80     edge          None
route.route.openshift.io/mc-shard-d   account.mc-sharded.com   /           router-internal-mc-shard-d   80     edge          None

NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                   AGE
service/router-internal-default      ClusterIP   172.31.242.67   <none>        80/TCP,443/TCP,1936/TCP   203d
service/router-internal-mc-shard     ClusterIP   172.31.194.51   <none>        80/TCP,443/TCP,1936/TCP   6h5m
service/router-internal-mc-shard-a   ClusterIP   172.31.104.31   <none>        80/TCP,443/TCP            53m
service/router-internal-mc-shard-c   ClusterIP   172.31.234.87   <none>        80/TCP,443/TCP            53m
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
service/router-internal-default      ClusterIP   172.30.158.83    <none>        80/TCP,443/TCP,1936/TCP   114d
service/router-internal-mc-shard     ClusterIP   172.30.128.59    <none>        80/TCP,443/TCP,1936/TCP   6h5m
service/router-internal-mc-shard-a   ClusterIP   172.30.79.165    <none>        80/TCP,443/TCP            53m
service/router-internal-mc-shard-c   ClusterIP   172.30.84.151    <none>        80/TCP,443/TCP            53m
service/router-internal-mc-shard-d   ClusterIP   172.30.128.103   <none>        80/TCP,443/TCP            53m
```

Edit the DNS to match the IP address in the BIG-IP (reported by the virtualserver resource). Next is an example when using dnsmasq:

```
$ sudo bash -c 'echo "address=/mc-sharded.com/10.1.10.102" > /etc/dnsmasq.d/mc-sharded.com.conf'
$ sudo systemctl restart dnsmasq
```

And run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


