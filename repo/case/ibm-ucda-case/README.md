# UrbanCode Deploy Agent - Case Bundle

## Introduction
[UrbanCode Deploy Agent](https://www.urbancode.com/product/deploy/) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Details
This CASE contains two inventory items:
- A helm chart that deploys a single instance of IBM UrbanCode Deploy agent that may be scaled to multiple instances.
- An operator that deploys a single instance of IBM UrbanCode Deploy agent that may be scaled to multiple instances.

Support has been validated on OpenShift clusters running onPrem, in IBM Satellite, and IBM ROKS.

The Persistent Volume access modes ReadWriteOnce (RWO) and ReadWriteMany (RWX) are both supported for use with IBM UrbanCode Deploy agent.  However, ReadWriteMany is required to successfully scale to more than one replica/instance of the agent.

## Kubernetes Roles and Personas
- Operator - The Kubernetes cluster administrator role is required when working with the UCD agent operator.  This role is required to add a new CustomResourceDefinition (CRD) named ucdagents.urbancode.ibm.com to the cluster.  Once the CRD has been added to the cluster, an instance of the operator can be installed into a namespace by a user with the namespace administrator role.  After the UCD agent operator is running, users can create UcdAgent resources.
- Helm Chart - Users with the namespace administrator role can install the UCD agent using the helm chart.

## Prerequisites
1. Kubernetes 1.16.0+; kubectl and oc CLI; Helm 3;
  * Install and setup oc/kubectl CLI depending on your architecture.
    * [ppc64le](https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [s390x](https://mirror.openshift.com/pub/openshift-v4/s390x/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [x86_64](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz)
  * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Accessing the container Image - The UrbanCode Deploy agent image is accessed via the IBM Entitled Registry.

    * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
    * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
    * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  If the secret is named ibm-entitlement-key it will be used as the default pull secret, no value needs to be specified in the image.secret field.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...', or the UcdAgent custom resource when installing via the operator.  Note that secrets are namespace scoped, so they must be created in every namespace you plan to install UrbanCode Deploy agent into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

  ```
  oc create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
  ```

3. The agent must have an UrbanCode Deploy server or relay to connect to.

4. Secret - A Kubernetes Secret object must be created to store the password for all keystores used by the product.  The name of the secret you create must be specified in the property 'secret.name' in your values.yaml if installing via Helm chart or in the UcdAgent custom resource if installing via operator.

  * Through the oc/kubectl CLI, create a Secret object in the target namespace.  Generate the base64 encoded value for the password for all keystores used by the product.

```
echo -n 'MyKeystorePassword' | base64
TXlLZXlzdG9yZVBhc3N3b3Jk
```

Create a file named secret.yaml with the following contents, using your secret name and base64 encoded values.

```
apiVersion: v1
kind: Secret
metadata:
  name: ucda-secrets
type: Opaque
data:
  keystorepassword: TXlLZXlzdG9yZVBhc3N3b3Jk
```

  * Create the Secret using oc apply

```
oc apply -f ./secret.yaml
```

  * Delete or shred the secret.yaml file.

5. A PersistentVolume that will hold the conf directory for the UrbanCode Deploy agent is required.  If your cluster supports dynamic volume provisioning you will not need to create a PersistentVolume (PV) or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucda-conf-vol
  labels:
    volume: ucda-conf-vol
spec:
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.1.17
    path: /volume1/k8/ucda-conf
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucda-conf-volc
spec:
  storageClassName: ""
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 10Mi
  selector:
    matchLabels:
      volume: ucda-conf-vol
```
* The following storage options have been tested with IBM UrbanCode Deploy

  * IBM Block Storage supports the ReadWriteOnce access mode.  ReadWriteMany is not supported.

  * IBM File Storage supports ReadWriteMany which is required for multiple instances of the UrbanCode Deploy agent.

* IBM UrbanCode Deploy requires non-root access to persistent storage. When using IBM File Storage you need to either use the IBM provided “gid” File storage class with default group ID 65531 or create your own customized storage class to specify a different group ID. Please follow the instructions at https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_storage#cs_storage_nonroot for more details.

6.  If a route or ingress is used to access the WSS port of the UrbanCode Deploy server from an UrbanCode Deploy agent, then port 443 should be specified along with the configured URL to access the proper service port defined for the UrbanCode Deploy Server.

### PodSecurityPolicy Requirements

If you are running on OpenShift, skip this section and continue to the [SecurityContextConstraints Requirements](#securitycontextconstraints-requirements) section below.

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy named [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

  * Custom PodSecurityPolicy definition:
```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is based on the most restrictive policy,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-ucd-prod-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      hostNetwork: false
      hostPID: false
      hostIPC: false
      requiredDropCapabilities:
      - ALL
      runAsUser:
        rule: MustRunAsNonRoot
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      volumes:
      - configMap
      - emptyDir
      - projected
      - secret
      - downwardAPI
      - persistentVolumeClaim
```

### SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. The default `SecurityContextConstraints` named restricted has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.


  * Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegeEscalation: true
  allowPrivilegedContainer: false
  allowedCapabilities: null
  defaultAddCapabilities: null
  fsGroup:
    type: MustRunAs
  metadata:
    annotations:
      kubernetes.io/description: restricted denies access to all host features and requires
        pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
        is the most restrictive SCC and it is used by default for authenticated users.
    name: ucda-restricted
  priority: null
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - KILL
  - MKNOD
  - SETUID
  - SETGID
  runAsUser:
    type: MustRunAsRange
  seLinuxContext:
    type: MustRunAs
  supplementalGroups:
    type: RunAsAny
  users: []
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  ```

## Resources Required
* 200MB of RAM
* 50 millicores CPU

# Installing UrbanCode Deploy agent operator

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
    --case ibm-ucda-case                  \
    --repo https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case \
    --outputdir /tmp/cases
```

Verify the case has been downloaded under the `/tmp/cases` directory.

## To install operator using OpenShift Operator Catalog

1. Install the catalog(s) via OLM

By default, TARGET_REGISTRY is `icr.io/cpopen`. You could export the TARGET_REGISTRY based on your desired image registry.

```
export TARGET_REGISTRY="Desired image registry"

cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
    --action install-catalog                           \
    --args "--recursive --inputDir /tmp/cases"
```

2. Install the operator via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
    --action install-operator
```

## To install UcdAgent operand

1. Once the operator is added to your cluster's OperatorHub and installed, you can create an instance of the UrbanCode Deploy agent via the Operators->Installed Operators page in the OpenShift web console.  Click on the UrbanCode Deploy agent tile in the list of installed operators.  Select the UcdAgent CR tab and click Create UcdAgent.  Fill in the form fields to provide the required information and click Create.

2. Alternatively, if you already have a UcdAgent resource yaml file, you can create an instance of the UrbanCode Deploy agent using the cloudctl CLI.

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
    --action apply_custom_resources                    \
    --args "--crFile <path-to-ucdagent_cr.yaml>"       \
    --tolerance 1
```

## To uninstall operator using OpenShift Operator Catalog
1. Uninstall the operator via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
    --action uninstall-operator
```

2. Uninstall the catalog via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
    --action uninstall-catalog                         \
    --args "--recursive --inputDir /tmp/cases"
```

## To install operator using command-line (non-OLM)
1. Install the operator via command line

By default, TARGET_REGISTRY is `icr.io/cpopen`. You could export the TARGET_REGISTRY based on your desired image registry.

```
export TARGET_REGISTRY="Desired image registry"

cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
    --action install-operator-native                   \
    --args "--registry $TARGET_REGISTRY --recursive --inputDir /tmp/cases"
```

## To uninstall operator using command-line (non-OLM)

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
    --action uninstall-operator-native                 \
    --args "--recursive --inputDir /tmp/cases"
```

## To install using helm chart

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ibmUcdaProd                            \
    --action install-helm-chart                        \
    --args "--helmReleaseName <Name of the helm release> --valuesPath <Path to the values.yaml> --helmChartPath <Path to the helm chart>"
```

## To uninstall using helm chart

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ibmUcdaProd                            \
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

The OpenShift image registry isn't recommended due to limitations such as lack of
support for fat manifest. Quay.io enterprise is an opensource alternative. To use
the image registry anyways:

1. Expose the OpenShift image registry externally

```
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
```

2. Set the environment variable of the target registry.

```
export TARGET_REGISTRY=$(oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}')
```

Otherwise, export the TARGET_REGISTRY environment variable with the location of
the registry.

#### 3. Configure Registry Auth

1. Create auth secret for the source image registry

Create registry secret for source image registry (if the registry is public which doesn't require credentials, this step can be skipped)

```
cloudctl case launch                                     \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz    \
    --namespace <target namespace>                       \
    --inventory ucdaOperatorSetup                        \
    --action configure-creds-airgap                      \
    --args "--registry cp.icr.io --user iamapikey --pass xyz"
```

2. Create auth secret for target image registry

```
cloudctl case launch                                     \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz    \
    --namespace <target namespace>                       \
    --inventory ucdaOperatorSetup                        \
    --action configure-creds-airgap                      \
    --args "--registry $TARGET_REGISTRY --user USERNAME --pass PASSWORD"
```

The credentials are now saved to `~/.airgap/secrets/<registry-name>.json`

#### 4. (Optional) Set the path of the target registry

If using OpenShift image registry, set the project to load the images to:

```
export TARGET_REGISTRY=$TARGET_REGISTRY/ucda
```

#### 5. Mirror Images

In this step image from saved CASE (images.csv) are copied to target registry in the airgap environment.

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
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
    --case /tmp/cases/ibm-ucda-case-1.4.6.tgz  \
    --namespace <target namespace>                     \
    --inventory ucdaOperatorSetup                      \
    --action configure-cluster-airgap                  \
    --args "--registry $TARGET_REGISTRY --inputDir /tmp/cases"
```

(Optional) If you are using an insecure registry, you must add the local registry to the cluster insecureRegistries list.

```
oc patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${TARGET_REGISTRY}'"]}}}'
```

#### 7. Install Operator

See instructions from [Installing UrbanCode Deploy agent](#installing-urbancode-deploy-agent-operator) section

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

See instructions from [Installing UrbanCode Deploy agent](#installing-urbancode-deploy-agent-operator) section


## Configuration

### Parameters

The Helm chart and operator custom resource have the following values.

#### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| version |  | UrbanCode Deploy agent product version |  |
| replicas | agent | Number of UCD agent replicas | Non-zero number of replicas.  Defaults to 1 |
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to Always |
|       | secret |  An image pull secret used to authenticate with the image registry | Empty (default) if no authentication is required to access the image registry. |
| license | accept | Set to true to indicate you have read and agree to license agreements : http://www-03.ibm.com/software/sla/sladb.nsf/searchlis/?searchview&searchorder=4&searchmax=0&query=(urbancode+deploy) | false |
| persistence | enabled | Determines if persistent storage will be used to hold the UCD agent conf directory contents. This should always be true to preserve agent data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "true" |
|             | fsGroup | The group ID to use to access persistent volumes | Default value "1001" |
| confVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the UCD agent conf directory is created by the chart. | Default value is "conf" |
|               | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the UCD agent conf directory. |  |
|               | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|               | size | Size of the volume to hold the UCD agent conf directory |  |
|              | accessMode | Persistent storage access mode for the conf directory persistent volume. | ReadWriteOnce |
| relayUri |  | Agent Relay Proxy URI if the agent is connecting to a relay. If multiple relays are specified, separate them with commas. For example, random:(http://relay1:20080,http://relay2:20080) |  |
| codestationUrl |  | Agent Relay Codestation URL. If multiple relays are specified, separate them with commas. For example, random:(http://relay1:20081,http://relay2:20081) |  |
| serverUri |  | UCD server URI. If multiple servers are specified, separate them with commas. For example, random:(wss://ucd1.example.com:7919,wss://ucd2.example.com:7919) |  |
| secret | name | Kubernetes secret which defines password to use when creating keystores. | |
| agentTeams |  | Teams to add this agent to when it connects to the UCD server.Format is <team>:<type>. Multiple team specifications are separated with a comma. |  |
| userUtils | existingClaimName | Name of existing Persistent Volume Claim that refers to Persistent Volume that contains executables for the agent process to execute as part of deployment processes. | |
|  | executablesPath | Relative pathname to the directory containing the user provided executable(s).  Comma separate multiple directory paths. | Default is '.', the top-level directory of the PV. |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | false (default) or true  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 2Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 50m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 200Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |



## Storage
See the Prerequisites section of this page for storage information.

## Limitations
