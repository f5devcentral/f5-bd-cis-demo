# Configuring CIS for multi cluster deployments

The scripts and information in this folder provide an opinionated way on how to deploy CIS in multi-cluster environments. 

In this, it is recommended to use only one CIS instance per BIG-IP and rely in BIG-IP HA groups to provide redundancy.

![alt text](https://raw.githubusercontent.com/f5devcentral/f5-bd-cis-demo/refs/heads/main/cis-multicluster-config/CIS-redundancy-with-hagroups.png "CIS redundancy with BIG-IP HA groups")

It is worth to remark that in this setup, CIS are configured as primary so services are automatically discovered in both clusters without requiring the use of extendedServiceReferences when using two clusters.

Throrough this guide the sample files asume clusters with alias ocp1, ocp2 and ocp3.

# Installing CIS

CIS will be deployed in two clusters, as the image above shows. Each CIS will be used for each BIG-IP.

## Preparations

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
# CIS version
CIS_VERSION=v2.18.0
# CIS NodePort health check. This information will be used also when configuring BIG-IP HA-groups.
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
```
## Configuring the CIS Extended ConfigMaps

CIS multicluster requires an Extended ConfigMap which contains the deployment topology. There is one of these ConfigMaps per CIS instance.

Use the provided sample files ```global-cm.ocp1.yaml``` and ```global-cm.ocp2.yaml``` and modify the namespace, cluster alias names as approppriate, including the file names of the manifests.

Note that the ``primaryEndPoint`` is not really used.

## Configuring CIS for its deployment
### CIS deployment with the CIS Operator (alternative)

If using the CIS Operator, edit the files ``operator/f5bigipctlr.ocp1.yaml`` and ``operator/f5bigipctlr.ocp2.yaml`` modifying the desired parameters.

Remember to rename these files with the ``<CLUSTER_ALIAS>`` of the target clusters.

### CIS deployment with a Deployment manifest (alternative)

If deploying with a plain Deployment manifest, edit the files ``deployment/f5-bigip-ctlr-deployment.ocp1.yaml`` and ``deployment/f5-bigip-ctlr-deployment.ocp2.yaml`` modifying the desired parameters.

Remember to rename these files with the ``<CLUSTER_ALIAS>`` of the target clusters.

## Running the scripts

Once the above configurations are completed installing the whole deployment consists in three steps:

- For each cluster, create the access that CIS will use.

  This creates a service account, API token, RBAC and a kubeconfig.
  
```
$ ./create-all-auth-configs.sh 
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

The following scripts are meant to be used directly by the user:


# Configuring BIG-IP HA groups

