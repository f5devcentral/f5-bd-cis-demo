# Table of contents

- demo-mc-twotier-istio-l7: multi-cluster Layer 7 two-tier demo using Istio ingress gateway in the second tier.

- demo-mc-twotier-nginx-l7: multi-cluster Layer 7 two-tier demo using NGINX in the second tier.

- demo-sc-twotier-haproxy-l7-shards: single-cluster Layer 7 two-tier demo using a separate shard of OpenShift's router (HA-proxy) in the second tier. See https://docs.openshift.com/container-platform/4.12/networking/ingress-sharding.html for details on route sharding.

- demo-sc-twotier-haproxy-l7-noshards: analogous to the previous demo but using the default OpenShift's router instance.

- demo-sc-twotier-istio-l4: single-cluster Layer 4 two-tier demo using Istio ingress gateway in the second tier.
  
- demo-sc-twotier-istio-l7: single-cluster Layer 7 two-tier demo using Istio ingress gateway in the second tier.

Each demo has it´s own README file.


Please note that given the demos use HTTPS monitors with SNI these need to be pre-created in advance. At present these cannot be created through CIS, see https://github.com/F5Networks/k8s-bigip-ctlr/issues/3236

