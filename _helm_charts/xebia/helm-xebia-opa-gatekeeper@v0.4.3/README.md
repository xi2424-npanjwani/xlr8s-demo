# Helm Chart OPA Gatekeeper and Constraint Templates
Helm Chart to create OPA Gatekeeper along with Constraint Templates

## Resources Created

### OPA Gatekeeper 
- Gatekeeper Admin
- Gatekeeper Audit 
- Gatekeeper Controller Manager
- Gatekeeper Critical Pods
- Gatekeeper Manager
- Gatekeeper Mutating Webhook
- Gatekeeper Validating Webhook 
- Gatekeeper Webhook Server

### Constraint Template
- K8sAllowedRepos
- K8sDisableHostNetworking
- K8sRunAsNonRoot
- K8sBlockNpLb     
- K8sPodPriority
- K8sCapsOnReplica  
- K8sRequiredProbes


## Install
Clone the repo and after opening the directory run the following command

```helm upgrade -i -n gatekeeper-system --create-namespace opa-gatekeeper .```

## Inputs
- Gatekeeper - [gatekeeper input](charts/gatekeeper/values.yaml)

## Dependencies 
 - Gatekeeper v3.8.1
