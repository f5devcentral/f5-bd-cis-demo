# Overview

Creates a multi-cluster L7 two-tier deployment with 3 clusters (ocp1, ocp2 and ocp3) where OpenShift´s Router default instance is used in the second tier.

L7 routes created in OpenShift´s Router (HA-proxy) and in BIG-IP:

```
www.multicluster.com/
www.multicluster.com/account
shop.multicluster.com/
```

The configuration in the BIG-IP will be in the mc-twotier partition

The demo requires configuring the DNS names with the IP allocated by the F5 IPAM controller. The IPAM controller requires a PersistentVolume. In the provided configuration NFS is used which is just fine for testing purposes.

# Install and Run the demo

Adapt the scripts use-context commands in the deploy-cis folder to suit your environment, with by default are as follows:

```
oc config use-context default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin
```

Adapt the file cis-config/deploy.cfg to suit your environment. This file contains passwords and cluster alias

Adapt the CIS deployment files to suit your environment:

```
cis-config/f5-bigip?-ctlr-deployment.clusterip.ocp?.yaml
```

Review the files cis-config/{values.yaml,ipam-pvc.yaml,ipam-pv.yaml} to adapt the IPAM provider and storage backend for the F5 IPAM operator.

Review the scripts run-clusters.sh and use-cluster.sh in the ../bin directory and adapt it to your environment

Once all the above is completed, run the script ./create-demo.sh which will:

- Install CIS and IPAM controller in the namespace cis-mc-twotier
- Create Route, Services and Deployments es in the applications namespace for OpenShift Router consumption in the second tier
- Create VirtualServer and Services in the namespace openshift-ingress (where the OpenShift Routers) is for the first tier

# Test the demo

Expect the following final configuration for the tier-1 (BIG-IP)

```
[cloud-user@ocp-provisioner video]$ run-clusters.sh oc -n openshift-ingress get vs
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME          HOST                    TLSPROFILENAME       HTTPTRAFFIC   IPADDRESS   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
route-blue    shop.multicluster.com   tls-reencrypt-shop                             test        10.1.10.112     Ok       28h
route-green   www.multicluster.com    tls-reencrypt-www                              test        10.1.10.112     Ok       28h
route-red     www.multicluster.com    tls-reencrypt-www                              test        10.1.10.112     Ok       28h
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME          HOST                    TLSPROFILENAME       HTTPTRAFFIC   IPADDRESS   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
route-blue    shop.multicluster.com   tls-reencrypt-shop                             test                                 28h
route-green   www.multicluster.com    tls-reencrypt-www                              test                                 28h
route-red     www.multicluster.com    tls-reencrypt-www                              test                                 28h
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
No resources found in openshift-ingress namespace.
Switching back to initial context default/api-ocp2-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
```

Expect the following configuration for the tier-2 (OpenShift Router/HA-proxy)

```
[cloud-user@ocp-provisioner video]$ run-clusters.sh oc -n applications get route
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME          HOST/PORT               PATH       SERVICES        PORT   TERMINATION   WILDCARD
route-blue    shop.multicluster.com   /          service-blue    8080   edge          None
route-green   www.multicluster.com    /account   service-green   8080   edge          None
route-red     www.multicluster.com    /          service-red     8080   edge          None
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME         HOST/PORT               PATH   SERVICES       PORT   TERMINATION   WILDCARD
route-blue   shop.multicluster.com   /      service-blue   8080   edge          None
route-red    www.multicluster.com    /      service-red    8080   edge          None
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
NAME          HOST/PORT               PATH       SERVICES        PORT   TERMINATION   WILDCARD
route-blue    shop.multicluster.com   /          service-blue    8080   edge          None
route-green   www.multicluster.com    /account   service-green   8080   edge          None
Switching back to initial context default/api-ocp2-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
```

Run the ./test-demo.sh to verify the deployment works as expected

# Delete the demo

Run the script ./delete-demo.sh


