# IBM UrbanCode Deploy - Case Bundle

## Introduction

[IBM UrbanCode Deploy](https://www.urbancode.com/product/deploy/) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Details
This CASE contains two inventory items:
- A helm chart that deploys a single server instance of IBM UrbanCode Deploy that may be scaled to multiple instances.
- An operator that deploys a single server instance of IBM UrbanCode Deploy that may be scaled to multiple instances.

Support has been validated on OpenShift clusters running onPrem, in IBM Satellite, and IBM ROKS.

The Persistent Volume access modes ReadWriteOnce (RWO) and ReadWriteMany (RWX) are both supported for use with IBM UrbanCode Deploy server.  However, ReadWriteMany is required to successfully scale to more than one replica/instance of the server.

## Kubernetes Roles and Personas
- Operator - The Kubernetes cluster administrator role is required when working with the UCD server operator.  This role is required to add a new CustomResourceDefinition (CRD) named ucdservers.urbancode.ibm.com to the cluster.  Once the CRD has been added to the cluster, an instance of the operator can be installed into a namespace by a user with the namespace administrator role.  After the UCD server operator is running, users can create UcdServer resources.
- Helm Chart - Users with the namespace administrator role can install the UCD server using the helm chart.

## Prerequisites

1. Kubernetes 1.16.0+; kubectl and oc CLI; Helm 3;
  * Install and setup oc/kubectl CLI depending on your architecture.
    * [ppc64le](https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [s390x](https://mirror.openshift.com/pub/openshift-v4/s390x/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [x86_64](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz)
  * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Accessing the container Image - The UrbanCode Deploy server image is  accessed via the IBM Entitled Registry.

  * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
  * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
  * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  If the secret is named ibm-entitlement-key it will be used as the default pull secret, no value needs to be specified in the image.secret field.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...', or the UcdServer custom resource when installing via the operator.  Note that secrets are namespace scoped, so they must be created in every namespace you plan to install UrbanCode Deploy server into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

```
oc create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
```

3. Database - UrbanCode Deploy requires a database.  The database may be running in your cluster or on hardware that resides outside of your cluster.  This database  must be configured as described in [Installing the server database](https://www.ibm.com/support/knowledgecenter/SS4GSP_7.1.1/com.ibm.udeploy.install.doc/topics/DBinstall.html) before installing the containerized UrbanCode Deploy server.  The values used to connect to the database are required when installing the UrbanCode Deploy server.  The Apache Derby database type is not supported when running the UrbanCode Deploy server in a Kubernetes cluster.

4. Secret - A Kubernetes Secret object must be created to store the initial UrbanCode Deploy server administrator password, the password used to access the database mentioned above, and the password for all keystores used by the UrbanCode Deploy server.  The name of the secret you create must be specified in the property 'secret.name' in your values.yaml if installing via Helm chart or in the UcdServer custom resource if installing via operator.

* Through the oc/kubectl CLI, create a Secret object in the target namespace.
    Generate the base64 encoded values for the initial UCD admin password, database password, and the password for all keystores used by the product.

```
echo -n 'admin' | base64
YWRtaW4=
echo -n 'MyDbpassword' | base64
TXlEYnBhc3N3b3Jk
echo -n 'MyKeystorePassword' | base64
TXlLZXlzdG9yZVBhc3N3b3Jk
```

  * Create a file named secret.yaml with the following contents, using your secret name and base64 encoded values.

```
apiVersion: v1
kind: Secret
metadata:
  name: ucd-secrets
type: Opaque
data:
  initpassword: YWRtaW4=
  dbpassword: TXlEYnBhc3N3b3Jk
  keystorepassword: TXlLZXlzdG9yZVBhc3N3b3Jk
```

  * Create the Secret using oc apply

```
oc apply -f ./secret.yaml
```

  * Delete or shred the secret.yaml file.

5. JDBC drivers - A PersistentVolume (PV) that contains the JDBC driver(s) required to connect to the database configured above must be created.  You must either:

* Create Persistence Storage Volume - Create a PV, copy the JDBC driver(s) to the PV, and create a PersistentVolumeClaim (PVC) that is bound to the PV. For more information on Persistent Volumes and Persistent Volume Claims, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes). Sample YAML to create the PV and PVC are provided below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucd-ext-lib
  labels:
    volume: ucd-ext-lib-vol
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.1.17
    path: /volume1/k8/ucd-ext-lib
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucd-ext-lib-volc
spec:
  storageClassName: ""
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 100Mi
  selector:
    matchLabels:
      volume: ucd-ext-lib-vol
```
* Dynamic Volume Provisioning - If your cluster supports [dynamic volume provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/), you may use it to create the PV and PVC. However, the JDBC drivers will still need to be copied to the PV. To copy the JDBC driver(s) to your PV during the chart installation process, first write a bash script that copies the JDBC driver(s) from a location accessible from your cluster to `${UCD_HOME}/ext_lib/`. Next, store the script, named `script.sh`, in a yaml file describing a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/).  Finally, create the ConfigMap in your cluster by running a command such as `oc create configmap <map-name> <data-source>`.  Below is an example ConfigMap yaml file that copies a MySQL .jar file from a web server using wget.

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: user-script
data:
  script.sh: |
    #!/bin/bash
    echo "Running script.sh..."
    if [ ! -f ${UCD_HOME}/ext_lib/mysql-jdbc.jar ] ; then
      echo "Copying file(s)..."    
      wget -L -O mysql-jdbc.jar http://webserver-example/mysql-jdbc.jar
      mv mysql-jdbc.jar ${UCD_HOME}/ext_lib/
      echo "Done copying."
    else
      echo "File ${UCD_HOME}/ext_lib/mysql-jdbc.jar already exists."
    fi
```
  * Note the script must be named `script.sh`.

6. A PersistentVolume that will hold the appdata directory for the UrbanCode Deploy server is required.  If your cluster supports dynamic volume provisioning you will not need to manually create a PersistentVolume (PV) or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucd-appdata-vol
  labels:
    volume: ucd-appdata-vol
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.1.17
    path: /volume1/k8/ucd-appdata
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucd-appdata-volc
spec:
  storageClassName: ""
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 20Gi
  selector:
    matchLabels:
      volume: ucd-appdata-vol
```
* The following storage options have been tested with IBM UrbanCode Deploy

  * IBM Block Storage supports the ReadWriteOnce access mode.  ReadWriteMany is not supported.

  * IBM File Storage supports ReadWriteMany which is required for Distributed Front End(DFE).

* IBM UrbanCode Deploy requires non-root access to persistent storage. When using IBM File Storage you need to either use the IBM provided “gid” File storage class with default group ID 65531 or create your own customized storage class to specify a different group ID. Please follow the instructions at https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_storage#cs_storage_nonroot for more details.

7.  If a route or ingress is used to access the WSS port of the UrbanCode Deploy server from an UrbanCode Deploy agent, then port 443 should be specified along with the configured URL to access the proper service port defined for the UrbanCode Deploy Server.

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

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation.  The default `SecurityContextConstraints` named restricted has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

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
    name: ucd-restricted
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

### Licensing Requirements

The UCD server image will attempt to upload UCD metrics(agent high-water mark) to the license service. Hence this case requires IBM Licensing operator which is part of IBM Common Services to be installed in the Openshift cluster. Please follow the instructions at https://www.ibm.com/support/knowledgecenter/SSHKN6/installer/landing_installer.html to install IBM Common services.

Once the common services are installed, IBM Licensing service would be accessible by the UCD server by running OperandRequest to copy the license service secret(ibm-licensing-upload-token secret) and configmap(ibm-licensing-upload-config configmap). Please follow the instructions at https://www.ibm.com/support/knowledgecenter/SSHKN6/installer/3.x.x/bind_info.html to copy the secret and configmap into your desired namespace. It is required to run OperandRequest only for the ibm-licensing-operator. Following is an example OperandRequest yaml which was tested with IBM Common Services operator 3.6.3.

```yaml
apiVersion: operator.ibm.com/v1alpha1
kind: OperandRequest
metadata:
  name: ibm-licensing-request
spec:
  requests:
  - operands:
      - name: ibm-licensing-operator
        bindings:
          public-api-upload:
            secret: ibm-licensing-upload-token
            configmap: ibm-licensing-upload-config
    registry: common-service
    registryNamespace: ibm-common-services
    description: "Requesting the Licensing Service"
```

To retrieve license usage data, please follow these [instructions](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2021.1?topic=service-retrieving-license-usage-data).

## Resources Required

* 4GB of RAM, plus 4MB of RAM for each agent
* 2 CPU cores, plus 2 cores for each 500 agents

# Installing UrbanCode Deploy server operator

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
    --case ibm-ucd-prod                  \
    --repo https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case \
    --outputdir /tmp/cases
```

Verify the case has been downloaded under the
`/tmp/cases` directory.

## To install operator using OpenShift Operator Catalog

1. Install the catalog(s) via OLM

By default, TARGET_REGISTRY is `icr.io/cpopen`. You could export the TARGET_REGISTRY based on your desired image registry.

```
export TARGET_REGISTRY="Desired image registry"

cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action install-catalog                           \
    --args "--recursive --inputDir /tmp/cases"
```

2. Install the operator via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action install-operator
```

## To install UcdServer operand

1. Once the operator is added to your cluster's OperatorHub and installed, you can create an instance of the UrbanCode Deploy server via the Operators->Installed Operators page in the OpenShift web console.  Click on the UrbanCode Deploy server tile in the list of installed operators.  Select the UcdServer CR tab and click Create UcdServer.  Fill in the form fields to provide the required information and click Create.

2. Alternatively, if you already have a UcdServer resource yaml file, you can create an instance of the UrbanCode Deploy server using the cloudctl CLI.

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action apply_custom_resources                    \
    --args "--crFile <path-to-ucdserver_cr.yaml>"      \
    --tolerance 1
```

## To uninstall operator using OpenShift Operator Catalog

1. Uninstall the operator via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action uninstall-operator
```

2. Uninstall the catalog via OLM

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action uninstall-catalog                         \
    --args "--recursive --inputDir /tmp/cases"
```

## To install operator using command-line (non-OLM)

1. Install the operator via command line

By default, TARGET_REGISTRY is `icr.io/cpopen`. You could export the TARGET_REGISTRY based on your desired image registry.

```
export TARGET_REGISTRY="Desired image registry"

cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action install-operator-native                   \
    --args "--registry $TARGET_REGISTRY --recursive --inputDir /tmp/cases"
```
* Once the operator is installed you can create an instance of the UrbanCode Deploy server by creating a UcdServer resource.

## To uninstall operator using command-line (non-OLM)

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action uninstall-operator-native                 \
    --args "--recursive --inputDir /tmp/cases"
```

## To install using helm chart

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ibmUcdProd                             \
    --action install-helm-chart                        \
    --args "--helmReleaseName <Name of the helm release> --valuesPath <Path to the values.yaml> --helmChartPath <Path to the helm chart>"
```

## To uninstall using helm chart

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz   \
    --namespace <target namespace>                     \
    --inventory ibmUcdProd                             \
    --action uninstall-helm-chart                      \
    --args "--helmReleaseName <Name of the helm release>"
```

### Configure Air-Gapped OpenShift Cluster With a Bastion Host

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
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz             \
    --namespace <target namespace>                       \
    --inventory ucdsOperatorSetup                        \
    --action configure-creds-airgap                      \
    --args "--registry cp.icr.io --user iamapikey --pass xyz"
```

2. Create auth secret for target image registry

```
cloudctl case launch                                     \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz             \
    --namespace <target namespace>                       \
    --inventory ucdsOperatorSetup                        \
    --action configure-creds-airgap                      \
    --args "--registry $TARGET_REGISTRY --user USERNAME --pass PASSWORD"
```

The credentials are now saved to `~/.airgap/secrets/<registry-name>.json`

#### 4. (Optional) Set the path of the target registry

If using OpenShift image registry, set the project to load the images to:

```
export TARGET_REGISTRY=$TARGET_REGISTRY/ucd
```

#### 5. Mirror Images

In this step image from saved CASE (images.csv) are copied to target registry in the airgap environment.

```
cloudctl case launch                                   \
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz           \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
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
    --case /tmp/cases/ibm-ucd-prod-1.5.7.tgz           \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action configure-cluster-airgap                  \
    --args "--registry $TARGET_REGISTRY --inputDir /tmp/cases"
```

(Optional) If you are using an insecure registry, you must add the local registry to the cluster insecureRegistries list.

```
oc patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${TARGET_REGISTRY}'"]}}}'
```

#### 7. Install Operator

See instructions from [Installing UrbanCode Deploy sever](#installing-urbancode-deploy-server-operator) section

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

See instructions from [Installing UrbanCode Deploy sever](#installing-urbancode-deploy-server-operator) section

## Configuration

### Parameters

The Helm chart and operator Custom Resource have the following values.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| version |  | UrbanCode Deploy product version |  |
| replicas | server | Number of UCD server replicas | Non-zero number of replicas.  Defaults to 1 |
|          | dfe | Number of DFE replicas | Number of Distributed Front End replicas.  Defaults to 0 |
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to Always |
|       | secret |  An image pull secret used to authenticate with the image registry | Empty (default) if no authentication is required to access the image registry. |
| service | type | Specify type of service | Valid options are ClusterIP, NodePort and LoadBalancer (for clusters that support LoadBalancer). Default is ClusterIP |
| database | type | The type of database UCD will connect to | Valid values are db2, mysql, oracle, and sqlserver |
|          | name | The name of the database to use |  |
|          | hostname | The hostname/IP of the database server | |
|          | port | The database port to connect to | |
|          | username | The user to access the database with | |
|          | jdbcConnUrl | The JDBC Connection URL used to connect to the database used by the UCD server. This value is normally constructed using the database type and other database field values, but must be specified here when using Oracle RAC/ORAAS or SQL Server with Integrated Security. | |
| secureConnections  | required | Specify whether UCD server connections are required to be secure | Default value is "true" |
| secret | name | Kubernetes secret which defines required UCD passwords. | You may leave this blank to use default name of HelmReleaseName-secrets where HelmReleaseName is the name of your Helm Release, otherwise specify the secret name here. |
| license | accept | Set to true to indicate you have read and agree to license agreements : http://www-03.ibm.com/software/sla/sladb.nsf/searchlis/?searchview&searchorder=4&searchmax=0&query=(urbancode+deploy) | false |
|  | serverURL | Information required to connect to the UCD license server. | Empty (default) to begin a 60-day evaluation license period.|
| persistence | enabled | Determines if persistent storage will be used to hold the UCD server appdata directory contents. This should always be true to preserve server data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "false" |
|             | fsGroup | The group ID to use to access persistent volumes | Default value "1001" |
| extLibVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the extlib directory is created by the chart. | Default value is "ext-lib" |
|              | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|              | size | Size of the volume used to hold the JDBC driver .jar files |  |
|              | existingClaimName | Persistent volume claim name for the volume that contains the JDBC driver file(s) used to connect to the UCD database. |  |
|              | configMapName | Name of an existing ConfigMap which contains a script named script.sh. This script is run before UrbanCode Deploy server installation and is useful for copying database driver .jars to the ext-lib persistent volume. |  |
|              | accessMode | Persistent storage access mode for the ext-lib persistent volume. | ReadWriteOnce |
| appDataVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the UCD server appdata directory is created by the chart. | Default value is "appdata" |
|               | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the UCD server appdata directory. |  |
|               | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|               | size | Size of the volume to hold the UCD server appdata directory |  |
|              | accessMode | Persistent storage access mode for the appdata persistent volume. | ReadWriteOnce |
| ingress | host | Host name used to access the UCD server UI. Leave blank on OpenShift to create default route. |  |
|               | dfehost | Host name used to access the UCD server distributed front end (DFE) UI. Leave blank on OpenShift to create default route. |  |
|               | wsshost | Host name used to access the UCD server WSS port. Leave blank on OpenShift to create default route. |  |
|               | jmshost | Host name used to access the UCD server JMS port. Leave blank on OpenShift to create default route. |  |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | true (default) or false  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 4000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 8Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 200m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 600Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|      readinessProbe     | initialDelaySeconds | Number of seconds after the container has started before the readiness probe is initiated | Default is 30 |
|           | periodSeconds | How often (in seconds) to perform the readiness probe | Default is 30 |
|           | failureThreshold | When a Pod starts and the probe fails, Kubernetes will try this number times before giving up. In the case of the readiness probe, the Pod will be marked Unready. | Default is 10 |
|      livenessProbe     | initialDelaySeconds | Number of seconds after the container has started before the liveness probe is initiated | Default is 300 |
|           | periodSeconds | How often (in seconds) to perform the liveness probe | Default is 300 |
|           | failureThreshold | When a Pod starts and the probe fails, Kubernetes will try this number times before giving up. Giving up in the case of the liveness probe means restarting the Pod. | Default is 3 |


## Storage
See the Prerequisites section of this page for storage information.

## Limitations

The Apache Derby database type is not supported when running the UrbanCode Deploy server in a Kubernetes cluster. This is because the containerized version is running in UCD HA mode, which does not support Derby.
