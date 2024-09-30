# f5-bd-cis-demo

This is a set of demos for CIS with either single or multiple OpenShift clusters. These are created using either:

- OpenShift Routes with F5 NextGen Route augmentation (see the routes folder) or
- F5 CRDs, a clean-sheet set of resource types for CIS (see the crds folder)

Each folder has its own description in a README file. Most of the demos have the following structure:

```
README.md ----------------> Description, usage of the demo
cis-config/ --------------> Configuration files and manifests to (un)deploy CIS and in some demos the IPAM controller as well
router-config/ -----------> When using Route shards, the configuration of these
routes-bigip/  -----------> L7 routes configuration for BIG-IP
routes-xxxxx/ ------------> When using an ingress controller, such as HA-proxy, Istio or NGINX, the configuration to configure the L7 routes in these
create-shards.sh ---------> When Route shards are used, this script needs to be run to create them before the actual demo
create-demo.sh -----------> Creates the demo itself, including the deployment of CIS (and IPAM if appropriate), the L7 routes in both tiers and the workloads
test-demo.sh -------------> Tests the L7 routes
delete-demo.sh -----------> Undoes the changes of create-demo.sh
delete-shards.sh ---------> Undoes the changes of create-shards.sh (should be called after delete-demo.sh)
```

For multi-cluster demos, there is a cis-multicluster-utils folder which contains two useful scripts used throrough in this repository:
```
use-cluster.sh -----------> Used to switch the contexts of the different clusters
run-cluster.sh -----------> Used to run a kubectl/oc command across all clusters defined in the CLUSTER_LIST environment variable 
```
You will need to adapt these to suit your environment before deploying the multi-cluster demos. Make sure that these scripts are in the $PATH.

