# UrbanCode Deploy Agent Relay - Case Bundle

## Introduction
[UrbanCode Deploy Agent Relay](https://www.urbancode.com/product/deploy/) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Details
This CASE contains two inventory items:
- A helm chart that deploys a single instance of IBM UrbanCode Deploy relay that may be scaled to multiple instances.
- An operator that deploys a single instance of IBM UrbanCode Deploy relay that may be scaled to multiple instances.

## Prerequisites

1. Kubernetes 1.16.0+; kubectl and oc CLI; Helm 3;
  * Install and setup oc/kubectl CLI depending on your architecture.
    * [ppc64le](https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [s390x](https://mirror.openshift.com/pub/openshift-v4/s390x/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [x86_64](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz)
  * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Accessing the container Image - The UrbanCode Deploy agent relay image is accessed via the IBM Entitled Registry.

    * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
    * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
    * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...', or the UcdRelay custom resource when installing via the operator.  Note that secrets are namespace scoped, so they must be created in every namespace you plan to install UrbanCode Deploy agent relay into.  Following is an example command to create an imagePullSecret named 'entitledregistry-secret'.

  ```
  oc create secret docker-registry entitledregistry-secret --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
  ```
3. The UrbanCode agent relay must have a UrbanCode Deploy server to connect to.

4. Secret - A Kubernetes Secret object must be created to store the UrbanCode Deploy server's Codestation authentication token and the password for all keystores used by the product.  The name of the secret you create must be specified in the property 'secret.name' in your values.yaml if installing via Helm chart or in the UcdRelay custom resource if installing via operator.

* Through the oc/kubectl CLI, create a Secret object in the target namespace.  Generate the base64 encoded values for the Codestation token and password for all keystores used by the product.

```
echo -n 255b21b7-ca48-4f2e-95c0-048fdbff4197 | base64
MjU1YjIxYjctY2E0OC00ZjJlLTk1YzAtMDQ4ZmRiZmY0MTk3
echo -n 'MyKeystorePassword' | base64
TXlLZXlzdG9yZVBhc3N3b3Jk
```

  * Create a file named secret.yaml with the following contents, using your secret name and base64 encoded values.

```
apiVersion: v1
kind: Secret
metadata:
  name: ucdr-secrets
type: Opaque
data:
  cspassword: MjU1YjIxYjctY2E0OC00ZjJlLTk1YzAtMDQ4ZmRiZmY0MTk3
  keystorepassword: TXlLZXlzdG9yZVBhc3N3b3Jk
```

  * Create the Secret using oc apply

```
oc apply -f ./secret.yaml
```

  * Delete or shred the secret.yaml file.

5. A PersistentVolume that will hold the conf directory for the UrbanCode Deploy relay is required.  If your cluster supports dynamic volume provisioning you will not need to create a PersistentVolume (PV) or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucdr-conf-vol
  labels:
    volume: ucdr-conf-vol
spec:
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.1.17
    path: /volume1/k8/ucdr-conf
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucdr-conf-volc
spec:
  storageClassName: ""
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 10Mi
  selector:
    matchLabels:
      volume: ucdr-conf-vol
```
* The following storage options have been tested with IBM UrbanCode Deploy

  * IBM Block Storage supports the ReadWriteOnce access mode.  ReadWriteMany is not supported.

  * IBM File Storage supports ReadWriteMany which is required for multiple instances of the UrbanCode Deploy agent.

* IBM UrbanCode Deploy requires non-root access to persistent storage. When using IBM File Storage you need to either use the IBM provided “gid” File storage class with default group ID 65531 or create your own customized storage class to specify a different group ID. Please follow the instructions at https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_storage#cs_storage_nonroot for more details.

6.  If a route or ingress is used to access the WSS port of the UrbanCode Deploy server from an UrbanCode Deploy relay, then port 443 should be specified along with the configured URL to access the proper service port defined for the UrbanCode Deploy Server.


### PodSecurityPolicy Requirements

The containerized UrbanCode Deploy relay works well with restricted security requirements. No root access is required.

### SecurityContextConstraints Requirements

The containerized UrbanCode Deploy agent works with the default OpenShift SecurityContextConstraint named 'restricted'. No root access is required.

## Resources Required
* 200MB of RAM
* 100 millicores CPU

# Installing UrbanCode Deploy relay operator

This operator can be installed in an on-line or air-gapped cluster through either of the following install paths :
1. Operator Lifecycle Manager (default)
2. Kubernetes CLI

## Download the case and case dependencies

Create a directory to save cases to a local directory

```
mkdir /tmp/cases
```

Run

```
cloudctl case save                       \
    --case ibm-ucdr-case                  \
    --repo https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case \
    --outputdir /tmp/cases
```

Verify the case, dependency cases and images csv has been downloaded under the
`/tmp/cases` directory.

## To install operator using OpenShift Operator Catalog

1. Install the catalog(s) via OLM

By default, TARGET_REGISTRY is `docker.io/ibmcom`. You could export the TARGET_REGISTRY based on your desired image registry.

```
export TARGET_REGISTRY="Desired image registry"

cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action install-catalog                           \
    --args "--recursive --inputDir /tmp/cases"
```

2. Install the operator via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action install-operator
```

## To install UcdRelay operand

1. Once the operator is added to your cluster's OperatorHub and installed, you can create an instance of the UrbanCode Deploy relay via the Operators->Installed Operators page in the OpenShift web console.  Click on the UrbanCode Deploy relay tile in the list of installed operators.  Select the UcdRelay CR tab and click Create UcdRelay.  Fill in the form fields to provide the required information and click Create.

2. Alternatively, if you already have a UcdRelay resource yaml file, you can create an instance of the UrbanCode Deploy relay using the cloudctl CLI.

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action apply_custom_resources                    \
    --args "--crFile <path-to-ucdrelay_cr.yaml>"       \
    --tolerance 1
```

## To uninstall operator using OpenShift Operator Catalog

1. Uninstall the operator via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action uninstall-operator
```

2. Uninstall the catalog via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action uninstall-catalog                         \
    --args "--recursive --inputDir /tmp/cases"
```

## To install operator using command-line (non-OLM)

1. Install the operator via command line

By default, TARGET_REGISTRY is `docker.io/ibmcom`. You could export the TARGET_REGISTRY based on your desired image registry.

```
export TARGET_REGISTRY="Desired image registry"

cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action install-operator-native                   \
    --args "--registry $TARGET_REGISTRY --recursive --inputDir /tmp/cases"
```

## To uninstall operator using command-line (non-OLM)

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz           \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action uninstall-operator-native                 \
    --args "--recursive --inputDir /tmp/cases"
```

## To install using helm chart

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ibmUcdrProd                            \
    --action install-helm-chart                        \
    --args "--helmReleaseName <Name of the helm release> --valuesPath <Path to the values.yaml> --helmChartPath <Path to the helm chart>"
```

## To uninstall using helm chart

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ibmUcdrProd                            \
    --action uninstall-helm-chart                      \
    --args "--helmReleaseName <Name of the helm release>"
```

### Configure Air-Gapped OpenShift Cluster With a Bastion

#### 1. Prepare Bastion Host

* Logon to the bastion machine

* Verify that the bastion machine has access
  * to public internet (to download CASE and images)
  * a target image registry ( where the images will be mirrored)
  * a target OpenShift cluster to install the operator

* Download and install dependent command line tools
  * [oc](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html#installing-the-cli) - To interact with OpenShift Cluster
  * [cloud-pak-cli](https://github.com/IBM/cloud-pak-cli) - To download and install CASE

All the following steps should be run from the bastion machine

#### 2. Set the TARGET_REGISTRY variable

The OpenShift image registry isn't recommended due to limitations such as lack of support for fat manifest. Quay.io enterprise is an opensource alternative. To use the OpenShift image registry anyways:

1. Expose the OpenShift image registry externally

```
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
```

2. Set the environment variable of the target registry.

```
export TARGET_REGISTRY=$(oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}')
```

Otherwise, export the TARGET_REGISTRY environment variable with the location of the registry.

#### 3. Configure Registry Auth

1. Create auth secret for the source image registry

Create registry secret for source image registry (if the registry is public which doesn't require credentials, this step can be skipped)

```
cloudctl case launch                                     \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz    \
    --namespace <target namespace>                       \
    --inventory ucdrOperatorSetup                        \
    --action configure-creds-airgap                      \
    --args "--registry cp.icr.io --user iamapikey --pass xyz"
```

2. Create auth secret for target image registry

```
cloudctl case launch                                     \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz    \
    --namespace <target namespace>                       \
    --inventory ucdrOperatorSetup                        \
    --action configure-creds-airgap                      \
    --args "--registry $TARGET_REGISTRY --user USERNAME --pass PASSWORD"
```

The credentials are now saved to `~/.airgap/secrets/<registry-name>.json`

#### 4. (Optional) Set the path of the target registry

If using OpenShift image registry, set the project to load the images to:

```
export TARGET_REGISTRY=$TARGET_REGISTRY/ucdr
```

#### 5. Mirror Images

In this step image from saved CASE (images.csv) are copied to target registry in the airgap environment.

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz           \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action mirror-images                             \
    --args "--registry $TARGET_REGISTRY --inputDir /tmp/cases"
```

#### 6. Configure Cluster for Airgap

This steps does the following

* creates a global image pull secret for the target registry (skipped if target registry is unauthenticated)
* creates a imagesourcecontentpolicy

WARNING:

* Cluster resources must adjust to the new pull secret, which can temporarily limit the usability of the cluster. Authorization credentials are stored in $HOME/.airgap/secrets and /tmp/airgap* to support this action

* Applying imagesourcecontentpolicy causes cluster nodes to recycle.

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucdr-case-@caseversion@.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdrOperatorSetup                      \
    --action configure-cluster-airgap                  \
    --args "--registry $TARGET_REGISTRY --inputDir /tmp/cases"
```

(Optional) If you are using an insecure registry, you must add the local registry to the cluster insecureRegistries list.

```
oc patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${TARGET_REGISTRY}'"]}}}'
```

#### 7. Install Operator

See instructions from [Installing UrbanCode Deploy relay](#installing-urbancode-deploy-relay-operator) section

### In Air-Gapped OpenShift Cluster Without a Bastion

#### 1. Prepare a portable device

Prepare a portable device (such as laptop) that be used to download the case and images can be carried into the air gapped environment

* Verify that the portable device has access
  * to public internet (to download CASE and images)
  * a target image registry ( where the images will be mirrored)
  * a target OpenShift cluster to install the operator

* Download and install dependent command line tools
  * [oc](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html#installing-the-cli) - To interact with Openshift Cluster
  * [cloud-pak-cli](https://github.com/IBM/cloud-pak-cli) - To download and install CASE

All the following steps should be run from the portable device

#### 2. Configure Registry Auth

See instructions from previous [Configure Registry Auth](#3-configure-registry-auth) section

#### 3. Mirror Images

See instructions from previous [Mirror Images](#5-mirror-images) section

#### 4. Configure Cluster for Airgap

See instructions from previous [Configure Cluster for Airgap](#6-configure-cluster-for-airgap) section

#### 5. Install the operator

See instructions from [Installing ibm-ucdr-case](#installing-urbancode-deploy-relay-operator) section


## Configuration

### Parameters

The Helm chart and operator custom resource have the following values.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| version |  | UrbanCode Deploy relay product vesion |  |
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to Always |
|       | secret |  An image pull secret used to authenticate with the image registry | Empty (default) if no authentication is required to access the image registry. |
| license | accept | Set to true to indicate you have read and agree to license agreements : http://ibm.biz/ucd-license | false |
| service | type | Specify type of service | Valid options are ClusterIP, NodePort and LoadBalancer (for clusters that support LoadBalancer). Default is ClusterIP |
| persistence | enabled | Determines if persistent storage will be used to hold the UCD server appdata directory contents. This should always be true to preserve server data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "false" |
|             | fsGroup | The group ID to use to access persistent volumes | Default value "1001" |
| confVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the UCD agent conf directory is created by the chart. | Default value is "conf" |
|            | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the UCD agent conf directory. |  |
|            | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|            | size | Size of the volume to hold the UCD agent conf directory |  |
|              | accessMode | Persistent storage access mode for the ext-lib persistent volume. | ReadWriteOnce |
| serverHostPort |  | UCD server hostname and WSS port in the form hostname:port. If specifying failover info, separate multiple hostname:port with a comma. For example, ucd1.example.com:7919,ucd2.example.com:7919) |  |
| secret | name | Kubernetes secret which defines required UCD passwords. | You may leave this blank to use default name of HelmReleaseName-secrets where HelmReleaseName is the name of your Helm Release, otherwise specify the secret name here. |
| codeStationReplication | enabled | Specify true to enable artifact caching on the relay. | false |
|                        | persisted | Specify true to persist the artifact cache when the relay container is restarted. | true |
|                        | serverUrl | The full URL of the central server to connect to, such as https://myserver.example.com:8443. |  |
|                        | maxCacheSize | The size to which to limit the artifact cache, such as 500M for 500 MB or 5G for 5 GB. To not put a limit on the cache, specify none. |  |
|                        | geotags | If you choose to cache files on the relay, you can specify one or more component version statuses here, separated by semicolons. The agent relay automatically caches component versions with any of these statuses so that those versions are ready when they are needed for a deployment. A status can contain a space except in the first or last position. A status can contain commas. The special * status replicates all artifacts, but use this status with caution, because it can make the agent relay store a large amount of data. If no value is specified, no component versions are cached automatically. |  |
| ingress | httpproxyhost | Host name used to access the UCD relay http proxy port. Leave blank on OpenShift to create default route. |  |
|               | codestationhost | Host name used to access the UCD relay codestation port. Leave blank on OpenShift to create default route. |  |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | false (default) or true  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 4000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 4Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 100m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 200Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |

## Storage
See the Prerequisites section of this page for storage information.

## Limitations
