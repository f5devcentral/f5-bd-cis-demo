#!/bin/bash

source config

### Templates

source templates/global-cm.cluster0.tmpl > global-cm.${CLUSTERS_ALIAS[0]}.yaml
source templates/global-cm.cluster1.tmpl > global-cm.${CLUSTERS_ALIAS[1]}.yaml

if [ $INSTALL_TYPE = "operator" ]; then
	source templates/f5bigipctlr.cluster0.tmpl > f5bigipctlr.${CLUSTERS_ALIAS[0]}.yaml
        source templates/f5bigipctlr.cluster1.tmpl > f5bigipctlr.${CLUSTERS_ALIAS[1]}.yaml
else
	source templates/f5-bigip-ctlr-deployment.cluster0.yaml > f5-bigip-ctlr-deployment.${CLUSTERS_ALIAS[0]}.yaml
        source templates/f5-bigip-ctlr-deployment.cluster1.yaml > f5-bigip-ctlr-deployment.${CLUSTERS_ALIAS[1]}.yaml
fi

### Authentication configuration

echo "Creating authentication configurations..."

for i in "${!CLUSTERS_ALIAS[@]}" ; do

	CLUSTER_ALIAS=${CLUSTERS_ALIAS[$i]}

        echo ">>> Cluster ${CLUSTER_ALIAS}"

	export KUBECONFIG=$(eval echo -n $KUBECONFIGS)
	kubectl config use-context $(eval echo -n $KUBECONTEXTS)
        eval $KUBELOGINS

	kubectl create ns ${CIS_NS} --dry-run=client -o yaml | kubectl apply -f -

	if [ $i -lt 2 ]; then # The clusters where CIS is installed

		kubectl label ns ${CIS_NS} f5bigipctlr="true" --overwrite
		./create-auth-config.sh ${CIS_NS} kubeconfig.${CLUSTER_ALIAS}.yaml cis-install
	else
		./create-auth-config.sh ${CIS_NS} kubeconfig.${CLUSTER_ALIAS}.yaml no-cis-install
	fi
done

