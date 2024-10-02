#!/bin/bash

CLUSTER_ALIAS=$1

if [ -z $CLUSTER_ALIAS ]; then

	echo "Needs to specify cluster alias as argument, ie: $0 cluster"
	exit 1
fi

source config

export KUBECONFIG=$(eval echo -n $KUBECONFIGS)
kubectl config use-context $(eval echo -n $KUBECONTEXTS)
eval $KUBELOGINS

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: cis-health-nodeport
  namespace: ${CIS_NS}
spec:
  ports:
  - name: cis-health-svc
    port: 8080
    protocol: TCP
    targetPort: 8080
    nodePort: ${CIS_NODEPORT}
  type: NodePort
  selector:
    app: f5-bigip-ctlr
EOF

kubectl create -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/${CIS_VERSION}/docs/config_examples/customResourceDefinitions/customresourcedefinitions.yml

kubectl create secret generic bigip-login --namespace ${CIS_NS} --from-literal=username=${BIGIP_USER} --from-literal=password=${BIGIP_PASS}

kubectl apply -f global-cm.${CLUSTER_ALIAS}.yaml

if [ $INSTALL_TYPE = "operator" ]; then
	kubectl apply -f f5bigipctlr.${CLUSTER_ALIAS}.yaml
else
	kubectl apply -f f5-bigip-ctlr-deployment.${CLUSTER_ALIAS}.yaml -n ${CIS_NS}
fi

for i in "${!CLUSTERS_ALIAS[@]}" ; do

	CLUSTER_KUBECONFIG=${CLUSTERS_ALIAS[$i]}
	kubectl create secret generic -n ${CIS_NS} kubeconfig.${CLUSTER_KUBECONFIG} --from-file=kubeconfig=kubeconfig.${CLUSTER_KUBECONFIG}.yaml
done

