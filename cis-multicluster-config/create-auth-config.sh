#!/bin/bash

CIS_NS="$1"
KUBECONTEXT="$2"
KUBECONFIG_FILE="$3"
CIS_INSTALL="$4"

if [ -z ${CIS_NS} ]; then

        echo "It is needed to specify CIS namespace as argument, ie: $0 <namespace> <kubecontext> <kubeconfig file> <cis-install|no-cis-install>"
        exit 1
fi

if [ -z ${KUBECONTEXT} ]; then

        echo "It is needed to specify the destination config file as argument, ie: $0 <namespace> <kubecontext> <kubeconfig file> <cis-install|no-cis-install>" 
        exit 1
fi

if [ -z ${KUBECONFIG_FILE} ]; then

        echo "It is needed to specify the destination config file as argument, ie: $0 <namespace> <kubecontext> <kubeconfig file> <cis-install|no-cis-install>"
        exit 1
fi

if [ -z ${CIS_INSTALL} ]; then

	echo "It is needed to specify if the auth configuration is for a cluster with CIS installed or a remote cluster, ie: $0 <namespace> <kubecontext> <kubeconfig file> <cis-install|no-cis-install>"
	exit 1
fi

kubectl create sa f5-bigip-ctlr-serviceaccount -n ${CIS_NS}

if [ ${CIS_INSTALL} = "cis-install" ]; then

	kubectl apply -f cis-cluster-rbac.yaml -n ${CIS_NS}

elif [ ${CIS_INSTALL} = "no-cis-install" ]; then
	
	kubectl apply -f external-cluster-rbac.yaml -n ${CIS_NS}

else

        echo "It is needed to specify if the auth configuration is for a cluster with CIS installed or a remote cluster, ie: $0 <namespace> <kubecontext> <kubeconfig file> <cis-install|no-cis-install>"
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
CLUSTER=$(kubectl config view --raw -o=go-template='{{range .contexts}}{{if eq .name "'''${KUBECONTEXT}'''"}}{{ index .context "cluster" }}{{end}}{{end}}')
SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')
CA=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CLUSTER}'''"}}"{{with index .cluster "certificate-authority-data" }}{{.}}{{end}}"{{ end }}{{ end }}')

cat << EOF > ${KUBECONFIG_FILE}
apiVersion: v1
kind: Config
current-context: bigip-ctlr-context
contexts:
- name: bigip-ctlr-context
  context:
    cluster: ${CLUSTER}
    user: f5-bigip-ctlr-serviceaccount
clusters:
- name: ${CLUSTER}
  cluster:
    certificate-authority-data: ${CA}
    server: ${SERVER}
users:
- name: f5-bigip-ctlr-serviceaccount
  user:
    token: ${USER_TOKEN_VALUE}
EOF



