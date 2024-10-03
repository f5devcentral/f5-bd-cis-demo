# Configuring CIS for multi cluster deployments

The scripts and information in this folder provide an opinionated way on how to deploy CIS in multi-cluster environments. 

In this, it is recommended to use only one CIS instance per BIG-IP and rely in BIG-IP HA groups to provide redundancy.

![alt text](https://raw.githubusercontent.com/f5devcentral/f5-bd-cis-demo/refs/heads/main/cis-multicluster-config/images/CIS-redundancy-with-hagroups.png "CIS redundancy with BIG-IP HA groups")

It is worth to remark that in this setup, CIS are configured as primary so services are automatically discovered in both clusters without requiring the use of extendedServiceReferences when using two clusters.

Throrough this guide the sample files asume clusters with alias ocp1, ocp2 and ocp3.

# Installing CIS

CIS will be deployed in two clusters, as the image above shows. Each CIS will be used for each BIG-IP.

## Preparations

- Install AS3 in the BIG-IPs
- Optional, install the CIS Operator
- Download this folder to the host where kubectl/oc commands can be run.
- For each cluster, make a copy of the kubeconfig file used by the user performing the installation. 

  This separate kubeconfigs will guarantee that while running the kubernetes commands the k8s context doesn´t change.
  Name the kubeconfig files like ``config.<CLUSTER_ALIAS>`` where ``<CLUSTER_ALIAS>`` will be used through the configuration and run of the scripts. 
  
- Make sure that the kubeconfig files contain the ``certificate-authority-data`` for the cluster.

## Configuring the scripts

Edit the ``config`` file in this folder. The file contains comments describing each field. See next an example. Please note that these scripts can be used with or without the CIS Operator.

```
# Namespace where CIS is installed
CIS_NS=f5bigipctlr
# Can be active-active, active-standby, ratio. Standalone mode not supported by this scripts.
CIS_MODE=active-active
# CIS version
CIS_VERSION=v2.18.0
# CIS NodePort health check
CIS_NODEPORT=30000
# BIG-IP credentials
BIGIP_USER=admin
BIGIP_PASS=OpenShiftMC
# The alias used for each OpenShift cluster, index 0 and 1 are the clusters where CIS is installed
CLUSTERS_ALIAS[0]=ocp1
CLUSTERS_ALIAS[1]=ocp2
CLUSTERS_ALIAS[2]=ocp3
# The path the KUBECONFIG file for each cluster, the value is run with "eval". Login and CLUSTER_ALIAS variables can be used.
KUBECONFIGS='$HOME/.kube/config.$CLUSTER_ALIAS'
# The name of the context for each cluster. CLUSTER_ALIAS variable can be used.
KUBECONTEXTS='default/api-${CLUSTER_ALIAS}-f5-udf-com:6443/f5admin'
# login command
KUBELOGINS='oc login -u f5admin -p f5admin'
# Select if you want to install using the OpenShift operator or just the plain Deployment file
INSTALL_TYPE=operator
# INSTALL_TYPE=deployment
# Where the IF5BigIpCtlr operator manifests are. Only used if $INSTALL_TYPE is operator.
OPERATOR_NS=openshift-operators
# BIGIP IP addresses where the AS3 API is exposed (either mgmt of self-IP, if exposed)
BIGIP_IP[0]=10.1.1.7
BIGIP_IP[1]=10.1.1.8
# The default partition that will be used unless specified in the CRDs
PARTITION_DEFAULT=mc-twotier
```
## Configuring CIS for its deployment
### CIS deployment with the CIS Operator (alternative)

If using the CIS Operator, edit the files ``templates/f5bigipctlr.cluster0.yaml`` and ``templates/f5bigipctlr.cluster1.yaml`` modifying the desired parameters.

### CIS deployment with a Deployment manifest (alternative)

If deploying with a plain Deployment manifest, edit the files ``templates/f5-bigip-ctlr-deployment.cluster0.yaml`` and ``templates/f5-bigip-ctlr-deployment.cluster1.yaml`` modifying the desired parameters.

## Running the scripts

Once the above pre-requisites are completed installing the whole deployment consists in three steps:

- Prepare the installation. This steps does:

  - Renders the template files (global configmap and operand/deployment file)
  - Creates the access that CIS will use for the clusters: service account, API token, RBAC and a kubeconfig for all clusters in a single run.
  
```
$ ./prepare-deployment.sh
Creating non authentication configurations...
Creating authentication configurations...
>>> Cluster ocp1
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
Login successful.

You have access to 84 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
namespace/f5bigipctlr created
namespace/f5bigipctlr labeled
serviceaccount/f5-bigip-ctlr-serviceaccount created
clusterrole.rbac.authorization.k8s.io/bigip-ctlr-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/bigip-ctlr-clusterrole-binding created
clusterrole.rbac.authorization.k8s.io/cluster-admin added: "f5-bigip-ctlr-serviceaccount"
secret/f5-bigip-ctlr-serviceaccount created
>>> Cluster ocp2
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
Login successful.

You have access to 81 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
namespace/f5bigipctlr created
namespace/f5bigipctlr labeled
serviceaccount/f5-bigip-ctlr-serviceaccount created
clusterrole.rbac.authorization.k8s.io/bigip-ctlr-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/bigip-ctlr-clusterrole-binding created
clusterrole.rbac.authorization.k8s.io/cluster-admin added: "f5-bigip-ctlr-serviceaccount"
secret/f5-bigip-ctlr-serviceaccount created
>>> Cluster ocp3
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
Login successful.

You have access to 83 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
namespace/f5bigipctlr configured
serviceaccount/f5-bigip-ctlr-serviceaccount created
clusterrole.rbac.authorization.k8s.io/bigip-ctlr-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/bigip-ctlr-clusterrole-binding created
clusterrole.rbac.authorization.k8s.io/cluster-admin added: "f5-bigip-ctlr-serviceaccount"
secret/f5-bigip-ctlr-serviceaccount created
```
- Deploy CIS in the first cluster

```
$ ./deploy-cis.sh ocp1
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
Login successful.

You have access to 85 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
service/cis-health-nodeport created
customresourcedefinition.apiextensions.k8s.io/virtualservers.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/tlsprofiles.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/transportservers.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/externaldnses.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/ingresslinks.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/policies.cis.f5.com created
secret/bigip-login created
configmap/global-cm.ocp1 created
f5bigipctlr.cis.f5.com/f5bigipctlr created
secret/kubeconfig.ocp1 created
secret/kubeconfig.ocp2 created
secret/kubeconfig.ocp3 created
```
- Deploy CIS in the second cluster

```
$ ./deploy-cis.sh ocp2
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
Login successful.

You have access to 82 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
service/cis-health-nodeport created
customresourcedefinition.apiextensions.k8s.io/virtualservers.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/tlsprofiles.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/transportservers.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/externaldnses.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/ingresslinks.cis.f5.com created
customresourcedefinition.apiextensions.k8s.io/policies.cis.f5.com created
secret/bigip-login created
configmap/global-cm.ocp2 created
f5bigipctlr.cis.f5.com/f5bigipctlr created
secret/kubeconfig.ocp1 created
secret/kubeconfig.ocp2 created
secret/kubeconfig.ocp3 created
```

Note that the deploy-cis.sh also installs the CIS CRDs.

The script ``create-auth-config.sh`` is not generally meant to be used directly by the user and is instead used by the ``create-all-auth-configs.sh``.

# Configuring BIG-IP HA groups

BIG-IP HA groups allows configuring conditions in which perform a failover. Conditions are for example when the BIG-IP is not able to reach an upstream gateway or when the the network interfaces are down. In the case of this integration, we are going to monitor the availability of CIS with the /ready endpoint, which is exposed with a NodePort Service by the deploy-cis.sh script. 

In the BIG-IPs, we will configure a pool for each CIS using the IPs of more than one Kubernetes node address for resiliency. Tipically, the pool members we will configure in the BIG-IP pools will be the master nodes because these are less likely to be changed. Using several pool members guarantee that in the case of node going down we still can properly monitor CIS properly.

The steps to configure this are:

1. Create an HTTP monitor for CIS

   ![alt text](https://github.com/f5devcentral/f5-bd-cis-demo/blob/main/cis-multicluster-config/images/http_cis_monitor.png?raw=true "Configuration of the NodePort pools for CIS")
   
3. Create pools bigip1_bigip1_cis_healthcheck and bigip2_bigip1_cis_healthcheck using as members the master nodes of CLUSTERS_ALIAS[0] and CLUSTERS_ALIAS[1] respectively. Apply the HTTP monitor for CIS just created. These are shown as red in the next image.
   
5. Create pools bigip1_bigip1_cis_nodecheck and bigip2_bigip1_cis_nodecheck using as members the master nodes of CLUSTERS_ALIAS[0] and CLUSTERS_ALIAS[1] respectively. Apply the gateway_icmp monitor. These are shown as blue in the next image.

   ![alt text](https://github.com/f5devcentral/f5-bd-cis-demo/blob/main/cis-multicluster-config/images/bigip_ha_groups_pools.png?raw=true "Configuration of the NodePort pools for CIS")
   
6. Perform a BIG-IP config-sync to the peer unit

7. Create an HA group in each BIG-IP independently

   Note that HA configuration in BIG-IP1 and BIG-IP2 monitor the CIS of ocp1 and ocp2 respectively
   
   Configuration in BIG-IP1 for CIS in the first cluster (ocp1)
   ![alt text](https://github.com/f5devcentral/f5-bd-cis-demo/blob/main/cis-multicluster-config/images/ha_group_bigip1.png?raw=true "HA group configuration for BIG-IP1 / first cluster")

   Configuration in BIG-IP2 for CIS in the second cluster (ocp2)
   ![alt text](https://github.com/f5devcentral/f5-bd-cis-demo/blob/main/cis-multicluster-config/images/ha_group_bigip2.png?raw=true "HA group configuration for BIG-IP1 / first cluster")

8. Assign the HA group to the traffic-group that CIS will manage

   ![alt text](https://github.com/f5devcentral/f5-bd-cis-demo/blob/main/cis-multicluster-config/images/traffic_group.png?raw=true "Assign the HA group to the traffic-group")
   
9. Perform a final BIG-IP config-sync
   
# Uninstalling

The three steps below remove everything that was installed in all clusters.

- Undo the configs created by ``create-all-auth-configs.sh``

```
$ ./undo-prepare-deployment.sh 
>>> Cluster ocp1
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
Login successful.

You have access to 85 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
serviceaccount "f5-bigip-ctlr-serviceaccount" deleted
clusterrole.rbac.authorization.k8s.io "bigip-ctlr-clusterrole" deleted
clusterrolebinding.rbac.authorization.k8s.io "bigip-ctlr-clusterrole-binding" deleted
secret "kubeconfig.ocp1" deleted
secret "kubeconfig.ocp2" deleted
secret "kubeconfig.ocp3" deleted
>>> Cluster ocp2
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
Login successful.

You have access to 82 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
serviceaccount "f5-bigip-ctlr-serviceaccount" deleted
clusterrole.rbac.authorization.k8s.io "bigip-ctlr-clusterrole" deleted
clusterrolebinding.rbac.authorization.k8s.io "bigip-ctlr-clusterrole-binding" deleted
secret "kubeconfig.ocp1" deleted
secret "kubeconfig.ocp2" deleted
secret "kubeconfig.ocp3" deleted
>>> Cluster ocp3
Switched to context "default/api-ocp3-f5-udf-com:6443/f5admin".
Login successful.

You have access to 83 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
serviceaccount "f5-bigip-ctlr-serviceaccount" deleted
clusterrole.rbac.authorization.k8s.io "bigip-ctlr-clusterrole" deleted
clusterrolebinding.rbac.authorization.k8s.io "bigip-ctlr-clusterrole-binding" deleted
```

- Undo the CIS installation in the second cluster
```
$ ./undeploy-cis.sh ocp2
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
Login successful.

You have access to 82 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
f5bigipctlr.cis.f5.com "f5bigipctlr" deleted
namespace "f5bigipctlr" deleted
```
- Undo the CIS installation in the first cluster
```
[cloud-user@ocp-provisioner cis-config]$ ./undeploy-cis.sh ocp1
Switched to context "default/api-ocp1-f5-udf-com:6443/f5admin".
Login successful.

You have access to 85 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
f5bigipctlr.cis.f5.com "f5bigipctlr" deleted
namespace "f5bigipctlr" deleted
```

Note that the ``undeploy.sh`` script removes the namespace where the CIS instances where deployed.

Note that by default, the ``undeploy.sh`` script doesn´t remove the CRDs. This is because removing the CRDs makes Kubernetes automatically remove any manifests (service configurations) created with these resources. If it is desired to remove the CRDs you can run the script with the ``delete-crds`` parameter. For example:

```
$ ./undeploy-cis.sh ocp2 delete-crds
Switched to context "default/api-ocp2-f5-udf-com:6443/f5admin".
Login successful.

You have access to 81 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "default".
f5bigipctlr.cis.f5.com "f5bigipctlr" deleted
namespace "f5bigipctlr" deleted
customresourcedefinition.apiextensions.k8s.io "virtualservers.cis.f5.com" deleted
customresourcedefinition.apiextensions.k8s.io "tlsprofiles.cis.f5.com" deleted
customresourcedefinition.apiextensions.k8s.io "transportservers.cis.f5.com" deleted
customresourcedefinition.apiextensions.k8s.io "externaldnses.cis.f5.com" deleted
customresourcedefinition.apiextensions.k8s.io "ingresslinks.cis.f5.com" deleted
customresourcedefinition.apiextensions.k8s.io "policies.cis.f5.com" deleted
```

The HA-groups configuration needs to be removed manually.
