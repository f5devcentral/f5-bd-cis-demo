#!/bin/bash

CIS_NS="$1"
KUBECONFIG_FILE="$2"
CIS_INSTALL="$3"

if [ -z ${CIS_NS} ]; then

        echo "It is needed to specify CIS namespace as argument, ie: $0 <namespace> <kubeconfig file> <cis-install|no-cis-install>"
        exit 1
fi

if [ -z ${KUBECONFIG_FILE} ]; then

        echo "It is needed to specify the destination config file as argument, ie: $0 <namespace> <kubeconfig file> <cis-install|no-cis-install>"
        exit 1
fi

if [ -z ${CIS_INSTALL} ]; then

	echo "It is needed to specify if the auth configuration is for a cluster with CIS installed or a remote cluster, ie: $0 <namespace> <kubeconfig file> <cis-install|no-cis-install>"
	exit 1
fi

kubectl create sa f5-bigip-ctlr-serviceaccount -n ${CIS_NS}

if [ ${CIS_INSTALL} = "cis-install" ]; then

	kubectl apply -f cis-cluster-rbac.yaml -n ${CIS_NS}

elif [ ${CIS_INSTALL} = "no-cis-install" ]; then
	
	kubectl apply -f external-cluster-rbac.yaml -n ${CIS_NS}

else

        echo "It is needed to specify if the auth configuration is for a cluster with CIS installed or a remote cluster, ie: $0 <namespace> <kubeconfig file> <cis-install|no-cis-install>"
        exit 1

fi

cat << EOF | kubectl apply -f -
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: bigip-ctlr-clusterrole-binding
  namespace: ${CIS_NS}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: bigip-ctlr-clusterrole
subjects:
  - apiGroup: ""
    kind: ServiceAccount
    name: f5-bigip-ctlr-serviceaccount
    namespace: ${CIS_NS}
EOF

eval oc >/dev/null 2>&1 && oc adm policy add-cluster-role-to-user cluster-admin -z f5-bigip-ctlr-serviceaccount -n ${CIS_NS}
kubectl apply -f kubeconfig-secret-token.yaml -n ${CIS_NS}

USER_TOKEN_VALUE=$(kubectl -n ${CIS_NS} get secret f5-bigip-ctlr-serviceaccount -o=jsonpath='{.data.token}' | base64 -d )
CURRENT_CONTEXT=$(kubectl config current-context)
CURRENT_CLUSTER=$(kubectl config view --raw -o=go-template='{{range .contexts}}{{if eq .name "'''${CURRENT_CONTEXT}'''"}}{{ index .context "cluster" }}{{end}}{{end}}')
CLUSTER_SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')
CLUSTER_CA=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}"{{with index .cluster "certificate-authority-data" }}{{.}}{{end}}"{{ end }}{{ end }}')

if [ -n ${CLUSTER_CA} ]; then
	CLUSTER_CA=$(kubectl config view --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')
fi

cat << EOF > ${KUBECONFIG_FILE}
apiVersion: v1
kind: Config
current-context: bigip-ctlr-context
contexts:
- name: bigip-ctlr-context
  context:
    cluster: ${CURRENT_CLUSTER}
    user: f5-bigip-ctlr-serviceaccount
clusters:
- name: ${CURRENT_CLUSTER}
  cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
users:
- name: f5-bigip-ctlr-serviceaccount
  user:
    token: ${USER_TOKEN_VALUE}
EOF



