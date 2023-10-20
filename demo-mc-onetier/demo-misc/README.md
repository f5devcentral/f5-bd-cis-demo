# Overview of Routes deployed

```
[cloud-user@ocp-provisioner demo-tls-and-nontls]$ run-clusters.sh oc -n mc-onetier-eng-caas-nginx-app1 get route
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME                     HOST/PORT                                PATH   SERVICES     PORT   TERMINATION            WILDCARD
nginx-app1               nginx-app1.apps.f5-udf.com                      nginx-app1   8080   edge/Redirect          None
nginx-app1-passthrough   nginx-app1-passthrough.apps.f5-udf.com          nginx-app1   8443   passthrough/Redirect   None
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME                     HOST/PORT                                PATH   SERVICES     PORT   TERMINATION            WILDCARD
nginx-app1               nginx-app1.apps.f5-udf.com                      nginx-app1   8080   edge/Redirect          None
nginx-app1-passthrough   nginx-app1-passthrough.apps.f5-udf.com          nginx-app1   8443   passthrough/Redirect   None
Switching back to initial context default/api-ocp2-f5-udf-com:6443/f5admin
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".

[cloud-user@ocp-provisioner demo-tls-and-nontls]$ run-clusters.sh oc -n mc-onetier-eng-caas-guestbook-app1 get route
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
NAME             HOST/PORT                        PATH   SERVICES         PORT   TERMINATION     WILDCARD
guestbook-app1   guestbook-app1.apps.f5-udf.com          guestbook-app1   3000   edge/Redirect   None
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
NAME             HOST/PORT                        PATH   SERVICES         PORT   TERMINATION     WILDCARD
guestbook-app1   guestbook-app1.apps.f5-udf.com          guestbook-app1   3000   edge/Redirect   None
```

# Tests overview

1. Test there is equitative load balancing

Use the following commands

ab -n 10000 -c 20 https://nginx-app1.apps.f5-udf.com/
ab -n 10000 -c 20 https://nginx-app1-passthrough.apps.f5-udf.com/

ab -n 10000 -c 20 https://guestbook-app1.apps.f5-udf.com/

To verify

tmsh -c "cd /mc-onetier ; show ltm pool recursive members raw" | egrep "Ltm::Pool|Total"

To reset the stats:

tmsh -c "cd /mc-onetier/Shared/ ; reset-stats ltm pool members"

2. Persistance test

Update the policy on the fly (cis-config folder)

```
run-clusters.sh oc apply -f policy-persistence.yaml
```

To reset the stats

tmsh -c "cd /mc-onetier/Shared/ ; reset-stats ltm pool members"

Re-run the tests

ab -n 10000 -c 20 https://nginx-app1.apps.f5-udf.com/
ab -n 10000 -c 20 https://nginx-app1-passthrough.apps.f5-udf.com/

ab -n 10000 -c 20 https://guestbook-app1.apps.f5-udf.com/

To verify

tmsh -c "cd /mc-onetier ; show ltm pool recursive members raw" | egrep "Ltm::Pool|Total"

Scale down the cluster where the requests went for https://nginx-app1.apps.f5-udf.com/ to verify that the requests no longer go where persistence was set

use-cluster.sh ocp1

oc -n mc-onetier-eng-caas-nginx-app1 scale deployment nginx-app1 --replicas=0

ab -n 20000 -c 20 https://nginx-app1.apps.f5-udf.com/

Verify again

tmsh -c "cd /mc-onetier ; show ltm pool recursive members raw" | egrep "Ltm::Pool|Total"

3. Scale to zero an application

4. Automatic end to end monitoring / autoMonitor: service-endpoint: Readiness, liveness and service endpoint probes

- when probe is not defined, creates a TCP probe using 5 interval, 3x5+1 timeout by default
- when probe is defined, creates a TCP probe using interval defined, 3xtimer+1 timeout
- timeout can be overriden with config map setting

when autoMonitor is: service-endpoint, liveness-probe or readiness-probe

- creates the probe using interval defined, uses 3xtimer+1 timeout instead of the defined timeout
- timeout can be overriden with config map setting

https://github.com/F5Networks/k8s-bigip-ctlr/pull/3099/commits/b717d2f27c4abeb6a68126609fec839108ba51be

5. Scale out an application while ab is running

Unset persistence for this test

run-clusters.sh oc apply -f policy-default.yaml

Some tests shown App Guestinfo with some errors, plain nginx doesn´t and passthrough doesn´t: the errors are because of guestinfo unable to cope with the load

- Commands for guestinfo test

```
ab -n 50000 -c 20 https://guestbook-app1.apps.f5-udf.com/

for r in 30 10 30 10; do echo $r ; oc -n mc-onetier-eng-caas-guestbook-app1 scale deployment guestbook-app1 --replicas=$r ; sleep 15 ; oc -n mc-onetier-eng-caas-guestbook-app1 get pods -l app=guestbook-app1 ; done
oc -n mc-onetier-eng-caas-guestbook-app1 scale deployment guestbook-app1 --replicas=3
```

- Commands for nginx and nginx-passthrough tests

```
ab -n 50000 -c 20 https://nginx-app1.apps.f5-udf.com/
ab -n 50000 -c 20 https://nginx-app1-passthrough.apps.f5-udf.com/

for r in 30 10 30 10; do echo $r ; oc -n mc-onetier-eng-caas-nginx-app1 scale deployment nginx-app1 --replicas=$r ; sleep 15 ; oc -n mc-onetier-eng-caas-nginx-app1 get pods ; done

oc -n mc-onetier-eng-caas-nginx-app1 scale deployment nginx-app1 --replicas=3
```

6. Update an application when running ab

```
oc -n mc-onetier-eng-caas-nginx-app1 scale deployment nginx-app1 --replicas=30
# make a dummy change
oc -n mc-onetier-eng-caas-nginx-app1 patch deployment nginx-app1 --patch '{"spec":{"template":{"spec":{"containers": [{"name":"nginx","env": [{"name":"DUMMY","value":"test12"}]}]}}}}'
```

Workloads
```
ab -n 50000 -c 20 https://nginx-app1.apps.f5-udf.com/
ab -n 50000 -c 20 https://nginx-app1-passthrough.apps.f5-udf.com/
```

7. Set cluster’s ratio to 0, while running ab

Running ab -n 50000 -c 20 https://nginx-app1.apps.f5-udf.com/

Verify
```
oc apply -f global-cm.yaml
# wait few secs, then reset the stat
tmsh -c "cd /mc-onetier/Shared/ ; reset-stats ltm pool members"
then wait some more secs and show the stats
tmsh -c "cd /mc-onetier ; show ltm pool recursive members raw" | egrep "Ltm::Pool|Total"
```

8. Connection limit

Set persistence to show how by default it is not overriden the connection limit. 

```
run-clusters.sh oc apply -f policy-persistence.yaml
```

Set the connection limit

oc annotate -n mc-onetier-eng-caas-nginx-app1 route/nginx-app1 virtual-server.f5.com/pod-concurrent-connections=10

Have 10 pool members for each cluster

```
run-clusters.sh oc -n mc-onetier-eng-caas-nginx-app1 scale deployment nginx-app1 --replicas=10
```

Use this workload: 

```
ab -n 20000 -c 20 https://nginx-app1.apps.f5-udf.com/
```

To verify

```
tmsh -c "cd /mc-onetier ; show ltm pool recursive members raw" | egrep "Ltm::Pool|Total"
```

To reset the stats:

```
tmsh -c "cd /mc-onetier/Shared/ ; reset-stats ltm pool members"
```
Set persistence to show how by default it is not overriden the connection limit

In the persistence profile there is a setting named "Override Connection Limit" but at present it cannot be applied. Let us know if this is required.

9. Blue-green deployment

  > See demo-weights

10. Change the ratio 80 to OCP1 and 20 to OCP2.

Modify the global-cm accordantly
```
run-clusters.sh oc apply -f global-cm.yaml
```
Reset the stats:

```
tmsh -c "cd /mc-onetier/Shared/ ; reset-stats ltm pool members"
```

To verify

```
tmsh -c "cd /mc-onetier ; show ltm pool recursive members raw" | egrep "Ltm::Pool|Total"
```

11. Apply X-Forwarded-For

apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: policy-default
  namespace: kube-system
spec:
  profiles:
    http: /Common/http-x-forwarded-for

The sample configuration the profile is applied to both HTTP and HTTPS traffic. It is possible to apply a different Policy CRD for the non HTTPS traffic.

12) Define a cypher suite in a per route basis

It can be specified a full SSL profile in a per route basis, which includes the cypher suite

[cloud-user@ocp-provisioner demo-weights]$ cat nginx-route.yaml 
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: nginx-app1
  namespace: eng-caas-nginx-app1
  labels:
    app: nginx-app1
    f5nr: "true"
    f5type: multicluster
  annotations:
    virtual-server.f5.com/clientssl: /Common/clientssl-secure


### Additional tests

Establish a keep alive connection and verify that this connection is not closed when scaling the Pods or setting ratio to 0

Useful commands:

```
[cloud-user@ocp-provisioner cis-multicluster]$ oc -n  mc-onetier-eng-caas-nginx-app1 scale deployment nginx-app1 --replicas=1
deployment.apps/nginx-app1 scaled
[cloud-user@ocp-provisioner cis-multicluster]$ oc -n  mc-onetier-eng-caas-nginx-app1 scale deployment nginx-app1 --replicas=4
deployment.apps/nginx-app1 scaled

socat - OPENSSL:nginx-app1.apps.f5-udf.com:443,verify=0

socat - OPENSSL:nginx-app1-passthrough.apps.f5-udf.com:443,verify=0

GET / HTTP/1.1
Host: something.apps.f5-udf.com

```

