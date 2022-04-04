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

```helm install <release-name> .```


## Steps to upgrade Gatekeeper chart 
1. Copy the upto-date Gatekeeper's chart directory into the repo's `/charts` directory after deleting the existing `gatekeeper ` directory in it.
2. Replace the keyword `.Release.Namespace` with `.Values.namespace` in the entire `/charts/gatekeeper` directory.
3. Add `Namespace: <namespace for gatekeeper resources>` into `charts/gatekeeper/values.yaml` file.
4. Add `namespace: {{ .Values.namespace | quote }}` to all the resources in `charts/gatekeeper/templates/namespace-post-install.yaml`.
5. Create a resource of type Namespace in `charts/gatekeeper/templates/` with `namespace: {{ .Values.namespace | quote }}`. 

## Inputs
- Gatekeeper - [gatekeeper input](charts/gatekeeper/values.yaml)

## Dependencies 
 - Gatekeeper v3.5.1
