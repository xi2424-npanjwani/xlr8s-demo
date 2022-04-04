# Helm Chart Kiali Operator
Helm Chart to setup Kiali using Kiali Operator


## Install
Clone the repo and after opening the directory run the following command 
to install the chart with the release name `kiali-operator` in the `kiali-system` namespace:

```
helm install --name kiali-operator --namespace kiali-operator helm-xebia-kiali
```

## Configuration

The following table lists the configurable parameters of the kiali-operator chart and their default values.

| Parameter                | Description                                                 | Default                                       |
| ------------------------ | ------------------------------------------------------------| ----------------------------------------------|
| `replicaCount`           | Number of operator replicas to create (only 1 is supported) | `1`                                           |
| `image.repository`       | kiali-operator container image                              | `quay.io/kiali/kiali-operator`                |
| `image.tag`              | kiali-operator container image tag                          | `v1.43`                                       |
| `external_services.prometheus.url` | Prometheus URL                                    | `prometheus.istio-system`                     |
| `cr.namespace`           | Kiali custom resource namespace                             | `.Release.Namespace`                          |
| `cr.deployment.namespace` | ingess namespace space                                     |                                               |

