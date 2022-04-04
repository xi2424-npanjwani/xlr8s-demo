# Helm Chart Istio
Helm Chart to setup Istio using Istio Operator

## Resources Created
- Istio Operator
- Istiod
- Istio Egressgateway
- Istio Ingressgateway

## Install
Clone the repo and after opening the directory run the following command

```helm install <release-name> .```

## Steps to upgrade Istio chart 
1. Copy the upto-date Istio Operator's chart directory into the repo's `/charts` directory after deleting the existing `istio-operator ` directory in it.

## Dependencies 
- Istio-Operator v1.10.2