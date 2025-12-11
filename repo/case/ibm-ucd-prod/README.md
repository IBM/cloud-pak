# IBM DevOps Deploy - Case Bundle

## Introduction

[IBM DevOps Deploy](https://www.ibm.com/cloud/urbancode/deploy) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Details
This CASE contains two inventory items:
- A helm chart that deploys a single server instance of IBM DevOps Deploy that may be scaled to multiple instances.
- An operator that deploys a single server instance of IBM DevOps Deploy that may be scaled to multiple instances.

Support has been validated on OpenShift clusters running onPrem, in IBM Satellite, and IBM ROKS.

The Persistent Volume access modes ReadWriteOnce (RWO) and ReadWriteMany (RWX) are both supported for use with IBM DevOps Deploy server.  However, ReadWriteMany is required to successfully scale to more than one replica/instance of the server.

## Kubernetes Roles and Personas
- Operator - The Kubernetes cluster administrator role is required when working with the DevOps Deploy server operator.  This role is required to add a new CustomResourceDefinition (CRD) named ucdservers.urbancode.ibm.com to the cluster.  Once the CRD has been added to the cluster, an instance of the operator can be installed into a namespace by a user with the namespace administrator role.  After the DevOps Deploy server operator is running, users can create UcdServer resources.
- Helm Chart - Users with the namespace administrator role can install the DevOps Deploy server using the helm chart.

## Prerequisites

1. Kubernetes 1.19.0+/OpenShift 4.12.0+; kubectl and oc CLI; Helm 3;
  * Install and setup oc/kubectl CLI depending on your architecture.
    * [ppc64le](https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [s390x](https://mirror.openshift.com/pub/openshift-v4/s390x/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [x86_64](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz)
  * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Accessing the container Image - The DevOps Deploy server image is  accessed via the IBM Entitled Registry.

  * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
  * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
  * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  If the secret is named ibm-entitlement-key it will be used as the default pull secret, no value needs to be specified in the image.secret field.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...', or the UcdServer custom resource when installing via the operator.  Note that secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Deploy server into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

```
oc create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
```

3. Database - DevOps Deploy requires a database.  The database may be running in your cluster or on hardware that resides outside of your cluster.  This database  must be configured as described in [Installing the server database](https://www.ibm.com/docs/en/devops-deploy/8.1.0?topic=installing-server-database) before installing the containerized DevOps Deploy server.  The values used to connect to the database are required when installing the DevOps Deploy server.

> **NOTE:** You have the option of automatically installing MySQL V8.0 during deployment of the DevOps Deploy server.  This can be done by specifying the "database.createDatabase: true" in the values.yaml settings used during deployment.  If this setting is specified, then a database will be created using the database name and database username specified in your settings.  The database password will be obtained from the Kubernetes secret object that is used during deployment of the DevOps Deploy server.

4. Secret - A Kubernetes Secret object must be created to store the initial DevOps Deploy server administrator password, the password used to access the database mentioned above, and the password for all keystores used by the DevOps Deploy server.  The name of the secret you create must be specified in the property 'secret.name' in your values.yaml if installing via Helm chart or in the UcdServer custom resource if installing via operator.

* Through the oc/kubectl CLI, create a Secret object in the target namespace.

```bash
oc create secret generic ucd-secrets \
  --from-literal=initpassword=admin \
  --from-literal=dbpassword=MyDbpassword \
  --from-literal=keystorepassword=MyKeystorePassword

```

> **NOTE:** If you need to change the keystorepassword after the initial server deployment, follow the instructions shown here: [Changing Password For Keystore Files](#changing-password-for-keystore-files).

> **NOTE:** If you do not create a Kubernetes Secret object prior to deployment, a secret will be created for you with randomized values for the passwords. The name of the secret will be `<helmReleaseName>-secrets` and will be created in the namespace of the Helm release. Follow the instructions provided in the output of the `helm get notes <helmReleaseName>` command to access the the contents of the auto-generated secret.

5. A PersistentVolume that will hold the appdata directory for the DevOps Deploy server is required.  If your cluster supports dynamic volume provisioning you will not need to manually create a PersistentVolume (PV) or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

  * Ensure that the spec.persistentVolumeReclaimPolicy parameter is set to Retain on the application data persistent volume. By default, the value is Delete for dynamically created persistent volumes. Setting the value to Retain ensures that the persistent volume is not freed or deleted if its associated persistent volume claim is deleted.

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
  persistentVolumeReclaimPolicy: Retain
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

  * The following storage options have been tested with IBM DevOps Deploy

    * IBM Block Storage supports the ReadWriteOnce access mode.  ReadWriteMany is not supported.

    * IBM File Storage supports ReadWriteMany which is required for Distributed Front End(DFE).

  * IBM DevOps Deploy requires non-root access to persistent storage. When using IBM File Storage you need to either use one of the IBM provided “gid” file storage classes (ie. ibmc-file-gold-gid) with default group ID 65531 or create your own customized storage class to specify a different group ID. See the information at https://cloud.ibm.com/docs/containers?topic=containers-cs_storage_nonroot for more details.  Once you know the correct group ID, set the persistence.fsGroup property in the values.yaml to that group ID.

6. JDBC drivers - DevOps Deploy is not packaged with the required JDBC driver(s) needed to access your database instance.  Multiple methods are available to add the required JDBC drivers(s) to your deployment:

* If "fetchDriver" is set to true in values.yaml, then the latest available JDBC driver version will be automatically downloaded for you from a maven repository based on the database type that you specified.  You also have the option of specifying the specific driverVersion that you wish to have downloaded if the latest version is not compatible with the database that is being used.

* If you want to download the JDBC driver(s) from a location that you define and you are using Dynamic Volume Provisioning to create the persistent storage that DevOps Deploy requires, then you can create a Kubernetes ConfigMap resource to copy the JDBC driver(s) to your PV during the chart installation process.  First write a bash script that copies the JDBC driver(s) from a location accessible from your cluster to `${UCD_HOME}/ext_lib/`. Next, store the script, named `script.sh`, in a yaml file describing a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/).  Finally, create the ConfigMap in your cluster by running a command such as `oc create configmap <map-name> <data-source>`.  Below is an example ConfigMap yaml file that copies a MySQL .jar file from a web server using wget.

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
* If you statically provision the persistent storage required by DevOps Deploy server to hold the appdata directory, then you can create a "ext_lib" subdirectory in that preallocated storage and copy the required JDBC driver(s) into that location prior to installing the server.

7.  If a route or ingress is used to access the WSS port of the DevOps Deploy server from an DevOps Deploy agent, then port 443 should be specified along with the configured URL to access the proper service port defined for the DevOps Deploy Server.

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
  allowPrivilegeEscalation: false
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
  - ALL
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

The DevOps Deploy server image will attempt to upload DevOps Deploy license metrics(agent high-water mark) to the IBM Lcense service. For the upload to be successful, this chart needs IBM Licensing operator (a component of IBM Foundational/Common Services) to be installed in the Openshift cluster. Please follow these [instructions](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.6?topic=service-installing-license) to install IBM License service.

Once the IBM License service is installed, you need to copy the license service upload secret(ibm-licensing-upload-token) and configmap(ibm-licensing-upload-config) to the namespace/project the DevOps Deploy server will be installed in. Be sure that the current namespace/project is the one that DevOps Deploy will be installed into, before running the following commands.

```bash
oc get secret ibm-licensing-upload-token -n ibm-licensing -o yaml | sed 's/^.*namespace: ibm-licensing.*$//' | oc create -f -
oc get configMap ibm-licensing-upload-config -n ibm-licensing -o yaml | sed 's/^.*namespace: ibm-licensing.*$//' | oc create -f -

```

Once the Deploy server has started emitting license metrics to the IBM License service (this can take up to 24 hours), you can retrieve license usage data by following these [instructions](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.6?topic=data-per-cluster-from-license-service).

## Resources Required

* 4GB of RAM, plus 4MB of RAM for each agent
* 2 CPU cores, plus 2 cores for each 500 agents

## Client Data Storage Locations

All client data is stored in either the user specified database or the appdata persistent volume.  DevOps Deploy does not do any active encryption of these data locations.  These locations should be included in whatever backup plans the user chooses to implement.

# Mirroring images

If your OpenShift cluster is unable to directly access the internet, you will need to mirror the DevOps Deploy images from the IBM Entitled Registry into a private container registry.  See instructions from [Mirroring images to a private container registry](#mirroring-images-to-a-private-container-registry)

# Installing DevOps Deploy server operator

This operator can be installed in an on-line or air-gapped cluster through either of the following install paths :
1. Operator Lifecycle Manager (default)
2. Kubernetes CLI

## Download the case and case dependencies

Run

```
oc ibm-pak get ibm-ucd-prod --version 2.0.22
```

## To install operator using OpenShift Operator Catalog

1. Install the catalog(s) via OLM

By default, TARGET_REGISTRY is `icr.io/cpopen`. You could export the TARGET_REGISTRY based on your desired image registry.

```
export TARGET_REGISTRY="Desired image registry"

oc ibm-pak launch ibm-ucd-prod        \
    --version 2.0.22           \
    --namespace <target namespace>    \
    --inventory ucdsOperatorSetup     \
    --action install-catalog
```

2. Install the operator via OLM

```
oc ibm-pak launch ibm-ucd-prod        \
    --version 2.0.22           \
    --namespace <target namespace>    \
    --inventory ucdsOperatorSetup     \
    --action install-operator
```

## To install UcdServer operand

1. Once the operator is added to your cluster's OperatorHub and installed, you can create an instance of the DevOps Deploy server via the Operators->Installed Operators page in the OpenShift web console.  Click on the DevOps Deploy server tile in the list of installed operators.  Select the UcdServer CR tab and click Create UcdServer.  Fill in the form fields to provide the required information and click Create.

2. Alternatively, if you already have a UcdServer resource yaml file, you can create an instance of the DevOps Deploy server using the 'oc ibm-pak' CLI.

```
oc ibm-pak launch ibm-ucd-prod                         \
    --version 2.0.22                            \
    --namespace <target namespace>                     \
    --inventory ucdsOperator                           \
    --action apply_custom_resources                    \
    --args "--crFile <path-to-ucdserver_cr.yaml>"      \
    --tolerance 1
```

## To upgrade UcdServer operand

1. You can upgrade an instance of the DevOps Deploy server via the Operators->Installed Operators page in the OpenShift web console.  Click on the DevOps Deploy server tile in the list of installed operators.  Select the UcdServer CR tab and click on the UcdServer instance you want to upgrade.  Select the YAML tab for the UcdServer instance, change the spec.version field to the DevOps Deploy version you want to upgrade to, then click Save.  The UcdServer operator will notice the change to the Custom Resource and begin the upgrade process.

## To uninstall operator using OpenShift Operator Catalog

1. Uninstall the operator via OLM

```
oc ibm-pak launch ibm-ucd-prod                         \
    --version 2.0.22                            \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action uninstall-operator
```

2. Uninstall the catalog via OLM

```
oc ibm-pak launch ibm-ucd-prod                         \
    --version 2.0.22                            \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action uninstall-catalog
```

## To install operator using command-line (non-OLM)

1. Install the operator via command line

By default, TARGET_REGISTRY is `icr.io/cpopen`. You could export the TARGET_REGISTRY based on your desired image registry.

```
export TARGET_REGISTRY="Desired image registry"

oc ibm-pak launch ibm-ucd-prod                         \
    --version 2.0.22                            \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action install-operator-native                   \
    --args "--registry $TARGET_REGISTRY"
```
* Once the operator is installed you can create an instance of the DevOps Deploy server by creating a UcdServer resource.

## To uninstall operator using command-line (non-OLM)

```
oc ibm-pak launch ibm-ucd-prod                         \
    --version 2.0.22                            \
    --namespace <target namespace>                     \
    --inventory ucdsOperatorSetup                      \
    --action uninstall-operator-native
```

## To install using helm chart

```
oc ibm-pak launch ibm-ucd-prod                         \
    --version 2.0.22                            \
    --namespace <target namespace>                     \
    --inventory ibmUcdProd                             \
    --action install-helm-chart                        \
    --args "--helmReleaseName <Name of the helm release> --valuesPath <Path to the values.yaml> --helmChartPath <Path to the helm chart>"
```

## To uninstall using helm chart

```
oc ibm-pak launch ibm-ucd-prod                         \
    --version 2.0.22                            \
    --namespace <target namespace>                     \
    --inventory ibmUcdProd                             \
    --action uninstall-helm-chart                      \
    --args "--helmReleaseName <Name of the helm release>"
```

## Changing Password For Keystore Files

To change the password used by the DevOps Deploy Server keystore files, follow these steps:

1. Scale the statefulset resource to 0 to shutdown the DevOps Deploy server.

2. Update the Kubernetes secret used to define the server passwords to set the **keystorepassword** to the new value.

3. **IMPORTANT:** Update the Kubernetes secret used to define the server passwords to set the **previouskeystorepassword** to the existing keystore password being used.

4. Scale the statefulset resource to 1 to restart the DevOps Deploy server.

5. When the server is restarted, the keystore passwords will be updated to the new value during pod initialization.

# Disaster Recovery

See the sections [Backup Kubernetes Resources](#Backup-Kubernetes-Resources), [Backup Product Data](#Backup-Product-Data) and [Recover from a Disaster](#Recover-from-a-disaster) to learn how you can recover your DevOps Deploy server instance after a disaster.

## Backup Kubernetes Resources

Backup the Kubernetes resoures required to redeploy the DevOps Deploy server after a disaster.  Follow these steps to save the configuration of essential Kubernetes resources.

1. Save UcdServer Custom Resource

   * Find the UcdServer Custom Resource name by running the following command.
```bash
oc get UcdServer --namespace <ucd_namespace>
```

   * Create a local copy of the UcdServer Custom Resource by running the following command.  Replace **cr_name** with the name of the UcdServer Custom Resource listed above.
```bash
oc get UcdServer/<cr_name> --namespace <ucd_namespace> -o yaml > <cr_name>-cr.yaml
```

   * Edit the local copy of the UcdServer Custom Resource and remove all .metadata fields other than labels and name, and remove all .status fields.

2. Save secret containing DevOps Deploy server product passwords

   a. Find the value for the secret.name property in the saved UcdServer Custom Resource file above.  This is the name of the secret we want to save a local copy of.  Run the following command, replacing **ucdsecrets_name** with the value from the secret.name property.
```bash
oc get secret <ucdsecrets_name> -n <ucd_namespace> -o yaml > <ucdsecrets_name>.yaml
```
3. Save image pull secret

   a. Find the value for the image.secret property in the saved UcdServer Custom Resource file above.  This is the name of the secret used to pull images from the IBM Entitled Registry.
   Run the following command, replacing **ibm-entitlement-key** with the value from the image.secret property.
```bash
oc get secret <ibm-entitlement-key> -n <ucd_namespace> -o yaml > <ibm-entitlement-key>.yaml
```
4. Save ext-lib configmap

   If a configmap was used to load the JDBC driver file into the ext-lib Persistent Volume, you will need to save a local copy of it.
   Find the value for the extLibVolume.configMapName property in the saved UcdServer Custom Resource file above.
   Run the following command, replacing **configMapName** with the value from the extLibVolume.configMapName property.
```bash
oc get configmap <configMapName> -n <ucd_namespace> -o yaml > <configMapName>.yaml
```

## Backup Product Data

Backup the database and appdata directory used by the DevOps Deploy server.  To ensure the most accurate saving of data, no deployments should be active.  Follow these steps to take a backup of the server.

1. Scale the statefulset resource to 0 to shutdown the DevOps Deploy server.

2. Create a full backup of the database.  For instructions on backing up the database, see the documentation from your database vendor.

3. Backup the appdata Persistent Volume.

4. Backup the ext-lib Persistent Volume (if present).

5. Scale the statefulset resource to 1 to restart the DevOps Deploy server.

## Recover from a disaster

If you have successfully backed up the resources and data as described in [Backup Kubernetes Resources](#backup-kubernetes-resources) and [Backup Product Data](#backup-product-data) you can recreate an instance of DevOps Deploy server using that data.  Follow these steps to recreate your DevOps Deploy server instance.

1. Create a new project/namespace to hold the Kubernetes resources associated with the DevOps Deploy server instance.

2. Create the Kubernetes secret that contains the DevOps Deploy server product passwords by running the following command.
```bash
oc apply -n <ucd_namespace> -f <ucdsecrets_name>.yaml
```
3. Create the image pull secret needed to access images in the IBM Entitled Registry by running the following command.
```bash
oc apply -n <ucd_namespace> -f <ibm-entitlement-key>.yaml
```
4. If your original DevOps Deploy server instance used a configMap resource to load the JDBC driver file into the ext-lib Persistent Volume, then recreate that configMap resource by running the following command.
```bash
oc apply -n <ucd_namespace> -f <configMapName>.yaml
```
Create the ext-lib Persistent Volume that the JDBC driver file will be loaded into.  Also create a Persistent Volume Claim that references the ext-lib Persistent Volume.  If you are not using a configMap to load the JDBC driver file into the ext-lib Persistent Volume, you will need to manually copy the JDBC driver file into the Persistent Volume.

5. Create the appdata Persistent Volume and associated Persistent Volume Claim and load the saved appdata directory contents into the Persistent Volume.

6. Follow the directions from your database vendor to create a new database from the backup/clone.

7. Create a UcdServer Custom Resource yaml file that contains the properties and values from your savedUcdServer-cr.yaml file.  Be sure that the extLibVolume.existingClaimName and appDataVolume.existingClaimName fields are set to the Persistent Volume Claims for the new ext-lib and appdata Persistent Volumes.  Also be sure that the database fields database.* refer to the new database instance created in the step above.

8. If the DevOps Deploy Server operator is not already installed in the OCP cluster, install it as described in [Installing DevOps Deploy server operator](#Installing-DevOps-Deploy-server-operator)

9. To create the restored DevOps Deploy server instance, see [To install UcdServer operand](#To-install-UcdServer-operand)


## Mirroring images to a private container registry

If your cluster is not connected to the internet, you can install the DevOps Deploy server in your cluster via connected or disconnected mirroring.

If you have a host that can access both the internet and your mirror registry, but not your cluster nodes, you can directly mirror the content from that machine. This process is referred to as **connected mirroring**. If you have no such host, you must mirror the images to a file system and then bring that host or removable media into your restricted environment. This process is referred to as **disconnected mirroring**.

### Before you begin

You must complete the steps in the following sections before you begin generating mirror manifests:

* [Prerequisites](#prerequisites)
* [Prepare a host](#prepare-a-host)
* [Set environment variables and download CASE files](#set-environment-variables-and-download-case-files)

**Important:** If you intend on installing using a private container registry, your cluster must support ImageContentSourcePolicy (ICSP).

#### Prerequisites

Regardless of whether you plan to mirror the images with a bastion host or to the file system, you must satisfy the following prerequisites:

- OpenShift requires you to have cluster admin access to run the `install-operator` command.

- An OpenShift cluster must be installed.

- Access to the following sites and ports:
  - `icr.io:443` for IBM Cloud Container Registry, CASE OCI artifact, and DevOps Deploy catalog source

**Tip:** With `ibm-pak` plug-in version 1.2.0, you can eliminate the port for `github.com` to retrieve CASES and tooling by configuring the plug-in to download CASEs as OCI artifacts from IBM Cloud Container Registry (ICCR): `oc ibm-pak config repo 'IBM Cloud-Pak OCI registry' -r oci:cp.icr.io/cpopen --enable`

#### Prepare a host

If you are in an air-gapped environment, you must be able to connect a host to the internet and mirror registry for connected mirroring or mirror images to file system which can be brought to a restricted environment for disconnected mirroring. For information on the latest supported operating systems, see [ibm-pak plugin install documentation](https://github.com/IBM/ibm-pak-plugin#overview).

The following table explains the software requirements for mirroring the DevOps Deploy server images:

|Software|Purpose|
|---|---|
|Docker|Container management|
|Podman|Container management|
|OpenShift CLI (oc)|Openshift administration|

Complete the following steps on your host:

1. Install Docker or Podman.

   To install Docker (for example, on Red Hat&reg; Enterprise Linux&reg;), run the following commands:

   **Note:** If you are installing as a non-root user you must use `sudo`. For more information, refer to the Podman or Docker documentation for installing as a non-root user.

   ```
   yum check-update
   yum install docker
   ```

   To install Podman, see [Podman Installation Instructions](https://podman.io/getting-started/installation.html).

2. Install the `oc` OpenShift CLI tool.

3. Download and install the most recent version of `IBM Catalog Management Plug-in for IBM Cloud Paks` from the [IBM/ibm-pak-plugin](https://github.com/IBM/ibm-pak-plugin). Extract the binary file by entering the following command:

   ```
   tar -xf oc-ibm_pak-linux-amd64.tar.gz
   ```

   Run the following command to move the file to the `/usr/local/bin` directory:

   **Note:** If you are installing as a non-root user you must use `sudo`. For more information, refer to the Podman or Docker documentation for installing as a non-root user.

   ```
   mv oc-ibm_pak-linux-amd64 /usr/local/bin/oc-ibm_pak
   ```

   **Note:** Download the plug-in based on the host operating system. You can confirm that `oc ibm-pak -h` is installed by running the following command:

   ```
   oc ibm-pak --help
   ```

   The plug-in usage is displayed.

   The plug-in is also provided in a container image `cp.icr.io/cpopen/cpfs/ibm-pak:TAG` where TAG should be replaced with the corresponding plugin version, for example `cp.icr.io/cpopen/cpfs/ibm-pak:v1.2.0` will have v1.2.0 of the plugin.

  The following command will create a container and copy the plug-ins for all the supported platforms in a directory, plugin-dir. You can specify any directory name and it will be created while copying. After copying, it will delete the temporary container. The plugin-dir will have all the binaries and other artifacts you find in a Github release and repo at [IBM/ibm-pak-plugin](https://github.com/IBM/ibm-pak-plugin).

   ```
   id=$(docker create cp.icr.io/cpopen/cpfs/ibm-pak:TAG - )
   docker cp $id:/ibm-pak-plugin plugin-dir
   docker rm -v $id
   cd plugin-dir
   ```

#### Creating registry namespaces

Top-level namespaces are the namespaces which appear at the root path of your private registry. For example, if your registry is hosted at `myregistry.com:5000`, then `mynamespace` in `myregistry.com:5000/mynamespace` is defined as a top-level namespace. There can be many top-level namespaces.

When the images are mirrored to your private registry, it is required that the top-level namespace where images are getting mirrored already exists or can be automatically created during the image push. If your registry does not allow automatic creation of top-level namespaces, you must create them manually.

When you generate mirror manifests, you can specify the top-level namespace where you want to mirror the images by setting `TARGET_REGISTRY` to `myregistry.com:5000/mynamespace` which has the benefit of needing to create only one namespace `mynamespace` in your registry if it does not allow automatic creation of namespaces.

If you do not specify your own top-level namespace, the mirroring process will use the ones which are specified by the CASEs. For example, it will try to mirror the images at `myregistry.com:5000/cp`, `myregistry.com:5000/cpopen etc`.

So if your registry does not allow automatic creation of top-level namespaces and you are not going to use your own during generation of mirror manifests, then you must create the following namespaces at the root of your registry.
- cp
- cpopen

There can be more top-level namespaces that you might need to create. See section on [Generate mirror manifests](#1.-generate-mirror-manifests) for information on how to use the `oc ibm-pak describe command` to list all the top-level namespaces.

#### Set environment variables and download CASE files

If your host must connect to the internet via a proxy, you must set environment variables on the machine that accesses the internet via the proxy server.

If you are mirroring via connected mirroring, set the following environment variables on the machine that accesses the internet via the proxy server:

```
export https_proxy=http://proxy-server-hostname:port
export http_proxy=http://proxy-server-hostname:port

# Example:
export https_proxy=http://server.proxy.xyz.com:5018
export http_proxy=http://server.proxy.xyz.com:5018
```

Before mirroring your images, you can set the environment variables on your mirroring device, and connect to the internet so that you can download the corresponding CASE files. To finish preparing your host, complete the following steps:

**Note**: Save a copy of your environment variable values to a text editor. You can use that file as a reference to cut and paste from when you finish mirroring images to your registry.

1. Create the following environment variables with the installer image name and the version.

   ```
   export CASE_NAME=ibm-ucd-prod
   export CASE_VERSION=2.0.22
   ```

2. Connect your host to the intranet.

3. The plug-in can detect the locale of your environment and provide textual helps and messages accordingly. You can optionally set the locale by running the following command:

   ```
   oc ibm-pak config locale -l LOCALE
   ```

   where LOCALE can be one of `de_DE`, `en_US`, `es_ES`, `fr_FR`, `it_IT`, `ja_JP`, `ko_KR`, `pt_BR`, `zh_Hans`, `zh_Hant`.

4. Configure the plug-in to download CASEs as OCI artifacts from IBM Cloud Container Registry (ICCR).

   ```
   oc ibm-pak config repo 'IBM Cloud-Pak OCI registry' -r oci:cp.icr.io/cpopen --enable
   ```

5. Enable color output (optional with v1.4.0 and later)

   ```
   oc ibm-pak config color --enable true
   ```

6. Download the image inventory for your DevOps Deploy server to your host.

   **Tip:** If you do not specify the CASE version, it will download the latest CASE.

   ```
   oc ibm-pak get $CASE_NAME --version $CASE_VERSION
   ```

By default, the root directory used by plug-in is `~/.ibm-pak`. This means that the preceding command will download the CASE under `~/.ibm-pak/data/cases/$CASE_NAME/$CASE_VERSION`. You can configure this root directory by setting the `IBMPAK_HOME` environment variable. Assuming `IBMPAK_HOME` is set, the preceding command will download the CASE under `$IBMPAK_HOME/.ibm-pak/data/cases/$CASE_NAME/$CASE_VERSION`.

The logs files will be available at `$IBMPAK_HOME/.ibm-pak/logs/oc-ibm_pak.log`.

Your host is now configured and you are ready to mirror your images.

**Notes:**

* Starting with v1.4.0, the plug-in creates a file, `component-set-config.yaml`, in the directory `~/.ibm-pak/data/cases/$CASE_NAME/$CASE_VERSION` to download the CASEs with `oc ibm-pak get`. This file captures all the CASEs that were downloaded, pinning down their exact versions during this particular download. You can use this file later to download the same CASEs with same versions in another environemnt. You can check in this file to your source code repository and recreate the same environment each time you use this to download the CASEs. Run the following command:

   ```
   oc ibm-pak get -c file:///home/user/ibm-pak/data/cases/$CASE_NAME/$CASE_VERSION/component-set-config.yaml
   ```

   * Note that the path after `file://` should be an absolute path.

* You can also edit this file defining the CASEs with pinned down versions which should include your product. The following is an example file, `my-csc.yaml`:

   ```
   name: "DevOps Deploy"                         # <required> defines the name for the "product"; this is NOT a CASE name, but follows IBM CASE name rules. For more information, see https://ibm.biz/case-yaml
   version: "7.3.1"                                # <required> defines a version for the "product"
   description: "an example product targeting OCP 4.9" # <optional, but recommended> defines a human readable description for this listing of components
   cases:                                          # list of CASEs. First item in the list is assumed to be the "top-level" CASE, and all others are dependencies
  - name: ibm-ucd-prod
    version: 2.0.22
    launch: true                                  # Exactly one CASE should have this field set to true. The launch scripts of that CASE are used as an entry point while executing 'ibm-pak launch' with a ComponentSetConfig
   ```

### Mirroring images to your private container registry

The process of mirroring images takes the image from the internet to your host, then effectively copies that image to your private container registry. After you mirror your images, you can configure your cluster and complete air-gapped installation.

Complete the following steps to mirror your images from your host to your private container registry:

- [1. Generate mirror manifests](#1.-generate-mirror-manifests)
- [2. Authenticating the registry](#2.-authenticating-the-registry)
- [3. Mirror images to final location](#3.-mirror-images-to-final-location)
- [4. Configure the cluster](#4.-configure-the-cluster)
- [5. Install DevOps Deploy server by way of OpenShift](#5.-install-devops-deploy-server-by-way-of-openshift)

#### 1. Generate mirror manifests

**Notes**:

* If you want to install subsequent updates to your air-gapped environment, you must do a `CASE get` to get the image list when performing those updates. A registry namespace suffix can optionally be specified on the target registry to group mirrored images.

1. Define the environment variable `$TARGET_REGISTRY` by running the following command:

   ```
   export TARGET_REGISTRY=<target-registry>
   ```

   The `<target-registry>` refers to the registry (hostname and port) where your images will be mirrored to and accessed by the oc cluster. For example setting TARGET_REGISTRY to `myregistry.com:5000/mynamespace` will create manifests such that images will be mirrored to the top-level namespace `mynamespace`.

2. Run the following command to generate mirror manifests to be used when mirroring the image to the target registry:

   ```
   oc ibm-pak generate mirror-manifests \
      $CASE_NAME \
      $TARGET_REGISTRY \
      --version $CASE_VERSION
   ```

The preceding command will generate the files, `images-mapping.txt` and `image-content-source-policy.yaml`, at `~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION`.

The `$TARGET_REGISTRY` refers to the registry where your images will be mirrored to and accessed by the `oc` cluster.

**Notes:**

- You can use the following command to list all the images that will be mirrored and the publicly accessible registries from where those images will be pulled from:

   ```
   oc ibm-pak describe $CASE_NAME --version $CASE_VERSION --list-mirror-images
   ```

   **Tip:** Note down the `Registries found` section at the end of output from the preceding command. You will need to log in to those registries so that the images can be pulled and mirrored to your local target registry. See the next steps on authentication. `Top-level namespaces found` section shows the list of namespaces under which the images will be mirrored. These namespaces should be created manually in your registry root path if your registry doesn't allow automatic creation of the namespaces.

##### **Example `~/.ibm-pak` directory structure**

The `~/.ibm-pak` directory structure is built over time as you save CASEs and mirror. The following tree shows an example of the `~/.ibm-pak` directory structure:

```
 tree ~/.ibm-pak
/root/.ibm-pak
├── config
│   └── config.yaml
├── data
│   ├── cases
│   │   └── YOUR-CASE-NAME
│   │       └── YOUR-CASE-VERSION
│   │           ├── XXXXX
│   │           ├── XXXXX
│   └── mirror
│       └── YOUR-CASE-NAME
│           └── YOUR-CASE-VERSION
│               ├── catalog-sources.yaml
│               ├── image-content-source-policy.yaml
│               └── images-mapping.txt
└── logs
    └── oc-ibm_pak.log
```

**Note:** A new directory `~/.ibm-pak/mirror` is created when you issue the `oc ibm-pak generate mirror-manifests` command. This directory holds the `image-content-source-policy.yaml`, `images-mapping.txt`, and `catalog-sources.yaml`.

If you are using a file system (disconnected mirroring), your `~/.ibm-pak` directory structure might look like the following:

```
 tree ~/.ibm-pak
/root/.ibm-pak
├── config
│   └── config.yaml
├── data
│   ├── cases
│   │   └── YOUR-CASE-NAME
│   │       └── YOUR-CASE-VERSION
│   │           ├── XXXX
│   │           ├── XXXX
│   └── mirror
│       └── YOUR-CASE-NAME
│           └── YOUR-CASE-VERSION
│               ├── catalog-sources.yaml
│               ├── image-content-source-policy.yaml
│               ├── images-mapping-to-filesystem.txt
│               └── images-mapping-from-filesystem.txt
└── logs
    └── oc-ibm_pak.log
```

A new directory `~/.ibm-pak/data/mirror` is created when you issue the `oc ibm-pak generate mirror-manifests` command. This directory holds the `image-content-source-policy.yaml`, `images-mapping-to-filesystem.txt`, `images-mapping-from-filesystem.txt`, and `catalog-sources.yaml`.

#### 2. Authenticating the registry

Complete the following steps to authenticate your registries:

1. Store authentication credentials for all source Docker registries.

   - `cp.icr.io`

   You must run the following command to configure credentials for all target registries that require authentication. Run the command separately for each registry:

   **Note:** The `export REGISTRY_AUTH_FILE` command only needs to run once.

   ```
   export REGISTRY_AUTH_FILE=<path to the file which will store the auth credentials generated on podman login>
   podman login <TARGET_REGISTRY>
   ```

   **Important:** When you log in to `cp.icr.io`, you must specify the user as `cp` and the password which is your Entitlement key from the [IBM Cloud Container Registry](https://myibm.ibm.com/products-services/containerlibrary). For example:

   ```
   podman login cp.icr.io
   Username: cp
   Password:
   Login Succeeded!
   ```

For example, if you export `REGISTRY_AUTH_FILE=~/.ibm-pak/auth.json`, then after performing `podman login`, you can see that the file is populated with registry credentials.

If you use `docker login`, the authentication file is typically located at `$HOME/.docker/config.json` on Linux or `%USERPROFILE%/.docker/config.json` on Windows. After `docker login` you should export `REGISTRY_AUTH_FILE` to point to that location. For example in Linux you can issue the following command:

```
export REGISTRY_AUTH_FILE=$HOME/.docker/config.json
```

|Directory|Description|
|---|---|
|`~/.ibm-pak/config`|Stores the default configuration of the plug-in and has information about the [public GitHub URL](https://github.com/IBM/cloud-pak/raw/master/repo/case/) from where the cases are downloaded.|
|`~/.ibm-pak/data/cases`|This directory stores the CASE files when they are downloaded by issuing the `oc ibm-pak get` command.|
|`~/.ibm-pak/data/mirror`|This directory stores the image-mapping files, ImageContentSourcePolicy manifest in `image-content-source-policy.yaml` and CatalogSource manifest in one or more `catalog-sourcesXXX.yaml`. The files  `images-mapping-to-filesystem.txt` and `images-mapping-from-filesystem.txt` are input to the `oc image mirror` command, which copies the images to the file system and from the file system to the registry respectively.|
|`~/.ibm-pak/data/logs`|This directory contains the `oc-ibm_pak.log` file, which captures all the logs generated by the plug-in.|

#### 3. Mirror images to final location

Complete the steps in this section on your host that is connected to both the local Docker registry and the OpenShift cluster.

1. Mirror images to the final location.

   - **For mirroring from a bastion host (connected mirroring):**

      Mirror images to the `TARGET_REGISTRY`:

      ```
      oc image mirror \
        -f ~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/images-mapping.txt \
        --filter-by-os '.*'  \
        -a $REGISTRY_AUTH_FILE \
        --insecure  \
        --skip-multiple-scopes \
        --max-per-registry=1 \
        --continue-on-error=true
      ```

      ```
      oc image mirror --help
      ```

      The above command can be used to see all the options available on the mirror command. Note that we use `continue-on-error` to indicate that command should try to mirror as much as possible and continue on errors.

      **Note:** Sometimes based on the number and size of images to be mirrored, the `oc image mirror` might take longer. If you are issuing the command on a remote machine it is recommended that you run the command in the background with a nohup so even if network connection to your remote machine is lost or you close the terminal the mirroring will continue. For example, the below command will start the mirroring process in background and write the log to `my-mirror-progress.txt`.

      ```
      nohup oc image mirror \
      -f ~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/images-mapping.txt \
      -a $REGISTRY_AUTH_FILE \
      --filter-by-os '.*' \
      --insecure \
      --skip-multiple-scopes \
      --max-per-registry=1 \
      --continue-on-error=true > my-mirror-progress.txt  2>&1 &
      ```

   You can view the progress of the mirror by issuing the following command on the remote machine:

      ```
      tail -f my-mirror-progress.txt
      ```

   - **For mirroring from a file system (disconnected mirroring):**

      Mirror images to your file system:

      ```
      export IMAGE_PATH=<image-path>
      oc image mirror \
        -f ~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/images-mapping-to-filesystem.txt \
        --filter-by-os '.*'  \
        -a $REGISTRY_AUTH_FILE \
        --insecure  \
        --skip-multiple-scopes \
        --max-per-registry=1 \
        --continue-on-error=true \
        --dir "$IMAGE_PATH"
      ```

      The `<image-path>` refers to the local path to store the images. For example, in the previous section if provided `file://local` as input during generate mirror-manifests, then the preceding command will create a subdirectory local under <image-path> and copy the images under it.

The following command can be used to see all the options available on the mirror command. Note that `continue-on-error` is used to indicate that the command should try to mirror as much as possible and continue on errors.

   ```
   oc image mirror --help
   ```

**Note:** Sometimes based on the number and size of images to be mirrored, the `oc image mirror` might take longer. If you are issuing the command on a remote machine, it is recommended that you run the command in the background with `nohup` so that even if you lose network connection to your remote machine or you close the terminal, the mirroring will continue. For example, the following command will start the mirroring process in the background and write the log to `my-mirror-progress.txt`.

   ```
    export IMAGE_PATH=<image-path>
    nohup oc image mirror \
      -f ~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/images-mapping-to-filesystem.txt \
      --filter-by-os '.*' \
      -a $REGISTRY_AUTH_FILE \
      --insecure \
      --skip-multiple-scopes \
      --max-per-registry=1 \
      --continue-on-error=true \
      --dir "$IMAGE_PATH" > my-mirror-progress.txt  2>&1 &
   ```

You can view the progress of the mirror by issuing the following command on the remote machine:

   ```
   tail -f my-mirror-progress.txt
   ```

2. **For disconnected mirroring only:** Continue to move the following items to your file system:

   * The `<image-path>` directory you specified in the previous step
   * The `auth` file referred by `$REGISTRY_AUTH_FILE`
   * `~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/images-mapping-from-filesystem.txt`

3. **For disconnected mirroring only:** Mirror images to the target registry from file system

   Complete the steps in this section on your file system to copy the images from the file system to the `$TARGET_REGISTRY`. Your file system must be connected to the target docker registry.

   **Important:** If you used the placeholder value of `TARGET_REGISTRY` as a parameter to `--final-registry` at the time of generating mirror manifests, then before running the following command, find and replace the placeholder value of `TARGET_REGISTRY` in the file, `images-mapping-from-filesystem.txt`, with the actual registry where you want to mirror the images. For example, if you want to mirror images to `myregistry.com/mynamespace` then replace `TARGET_REGISTRY` with `myregistry.com/mynamespace`.

   1. Run the following command to copy the images (referred in the `images-mapping-from-filesystem.txt` file) from the v2 directory to the final target registry:

      ```
      export IMAGE_PATH=<image-path>
      oc image mirror \
        -f ~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/images-mapping-from-filesystem.txt \
        -a $REGISTRY_AUTH_FILE \
        --from-dir "$IMAGE_PATH" \
        --filter-by-os '.*' \
        --insecure \
        --skip-multiple-scopes \
        --max-per-registry=1 \
        --continue-on-error=true
      ```

#### 4. Configure the cluster

1. Update the global image pull secret for your OpenShift cluster. Follow the steps in [Updating the global cluster pull secret](https://docs.openshift.com/container-platform/4.10/openshift_images/managing_images/using-image-pull-secrets.html#images-update-global-pull-secret_using-image-pull-secrets).

The documented steps in the link enable your cluster to have proper authentication credentials in place to pull images from your `TARGET_REGISTRY` as specified in the `image-content-source-policy.yaml` which you will apply to your cluster in the next step.

2. Create ImageContentSourcePolicy

   **Important:**

     * Before you run the command in this step, you must be logged into your OpenShift cluster. Using the `oc login` command, log in to the OpenShift cluster where your final location resides. You can identify your specific oc login by clicking the user drop-down menu in the OpenShift console, then clicking **Copy Login Command**.

     * The recommended way to install the catalog is to run the following command:

        ```
        oc apply -f ~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/catalog-sources.yaml
        ```

        The following command can also be used to install the catalog:

           ```
           oc ibm-pak launch \
           $CASE_NAME \
             --version $CASE_VERSION \
             --action install-catalog \
             --inventory $CASE_INVENTORY_SETUP \
             --namespace $NAMESPACE \
             --args "--registry $TARGET_REGISTRY/ --recursive \ --inputDir ~/.ibm-pak/data/cases/$CASE_NAME/$CASE_VERSION"
           ```

     * If you used the placeholder value of `TARGET_REGISTRY` as a parameter to `--final-registry` at the time of generating mirror manifests, then before running the following command, find and replace the placeholder value of `TARGET_REGISTRY` in file, `~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/image-content-source-policy.yaml` with the actual registry where you want to mirror the images. For example, replace `TARGET_REGISTRY` with `myregistry.com/mynamespace`.

   Run the following command to create ImageContentSourcePolicy:

      ```
      oc apply -f  ~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/image-content-source-policy.yaml
      ```

   If you are using OpenShift version 4.7 or earlier, this step might cause your cluster nodes to drain and restart sequentially to apply the configuration changes.

3. Verify that the ImageContentSourcePolicy resource is created.

   ```
   oc get imageContentSourcePolicy
   ```

4. Verify your cluster node status and wait for all the nodes to be restarted before proceeding.

   ```
   oc get MachineConfigPool
   ```

   ```
   $ oc get MachineConfigPool -w
   NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT   AGE
   master   rendered-master-53bda7041038b8007b038c08014626dc   True      False      False      3              3                   3                     0                      10d
   worker   rendered-worker-b54afa4063414a9038958c766e8109f7   True      False      False      3              3                   3                     0                      10d
   ```

   After the `ImageContentsourcePolicy` and global image pull secret are applied, the configuration of your nodes will be updated sequentially. Wait until all `MachineConfigPools` are in the `UPDATED=True` status before proceeding.

5. Create a new project for the CASE commands by running the following commands:

   **Note:** You must be logged into a cluster before performing the following steps.

   ```
   export NAMESPACE=<YOUR_NAMESPACE>
   ```

   ```
   oc new-project $NAMESPACE
   ```

6. **Optional:** If you use an insecure registry, you must add the target registry to the cluster insecureRegistries list.

   ```
   oc patch image.config.openshift.io/cluster --type=merge \
   -p '{"spec":{"registrySources":{"insecureRegistries":["'${TARGET_REGISTRY}'"]}}}'
   ```

7. Verify your cluster node status and wait for all the nodes to be restarted before proceeding.

   ```
   oc get MachineConfigPool -w
   ```

   After the `ImageContentsourcePolicy` and global image pull secret are applied, the configuration of your nodes will be updated sequentially. Wait until all `MachineConfigPools` are updated.

### 5. Install DevOps Deploy server by way of OpenShift

Now that your images are mirrored to your air-gapped environment, you can deploy your DevOps Deploy server to that environment. See the instructions at [Install DevOps Deploy server](#installing-devops-deploy-server-operator).

### Setting up a repeatable mirroring process

Once you complete a `CASE` save, you can mirror the `CASE` as many times as you want to. This approach allows you to mirror a specific version of the DevOps Deploy server into development, test, and production stages using a private container registry.

Follow the steps in this section if you want to save the `CASE` to multiple registries (per environment) once and be able to run the `CASE` in the future without repeating the `CASE` save process.

1. Run the following command to save the `CASE` to ~/.ibm-pak/data/cases/$CASE_NAME/$CASE_VERSION which can be used as an input during the mirror manifest generation:

   ```
   oc ibm-pak get \
   $CASE_NAME \
   --version $CASE_VERSION
   ```

2. Run the `oc ibm-pak generate mirror-manifests` command to generate the `image-mapping.txt`:

   ```
   oc ibm-pak generate mirror-manifests \
   $CASE_NAME \
   $TARGET_REGISTRY \
   --version $CASE_VERSION
   ```

   Then add the `image-mapping.txt` to the `oc image mirror` command:

   ```
   oc image mirror \
     -f ~/.ibm-pak/data/mirror/$CASE_NAME/$CASE_VERSION/images-mapping.txt \
     --filter-by-os '.*'  \
     -a $REGISTRY_AUTH_FILE \
     --insecure  \
     --skip-multiple-scopes \
     --max-per-registry=1 \
     --continue-on-error=true
   ```

If you want to make this repeatable across environments, you can reuse the same saved `CASE` cache (~/.ibm-pak/$CASE_NAME/$CASE_VERSION) instead of executing a `CASE` save again in other environments. You do not have to worry about updated versions of dependencies being brought into the saved cache.

## Configuration

### Parameters

The Helm chart and operator Custom Resource (UcdServer CR v4) have the following values.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| version |  | DevOps Deploy product version | Defaults to latest product version |
| replicas | server | Number of DevOps Deploy server replicas | Non-zero number of replicas.  Defaults to 1 |
|          | dfe | Number of DFE replicas | Number of Distributed Front End replicas.  Defaults to 0 |
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to IfNotPresent |
|       | secret |  An image pull secret used to authenticate with the image registry | If no value is specified we will look for a pull secret named ibm-entitlement-key. |
| service | type | Specify type of service | Valid options are ClusterIP, NodePort and LoadBalancer (for clusters that support LoadBalancer). Default is ClusterIP |
|         | annotations | Annotations for the service | Default value is "" |
|         | loadBalancerClass | https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-class | Default value is "" |
|         | loadBalancerSourceRanges | https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service | Default value is none |
| database | type | The type of database DevOps Deploy will connect to | Valid values are db2, mysql, oracle, and sqlserver.  Default is mysql. This value is ignored if database.createDatabase=true. |
|          | name | The name of the database to use | Default is "deploydb" |
|          | hostname | The hostname/IP of the database server. This value is ignored if database.createDatabase=true. | |
|          | port | The database port to connect to. This value is ignored if database.createDatabase=true. |  |
|          | username | The user to access the database with | Default is "dbuser" |
|          | jdbcConnUrl | The JDBC Connection URL used to connect to the database used by the DevOps Deploy server. This value is normally constructed using the database type and other database field values, but must be specified here when using Oracle RAC/ORAAS or SQL Server with Integrated Security.  If a value is specified here, the other database properties are ignored.| |
|          | fetchDriver | Boolean specifying whether to fetch JDBC driver from well-known location.  Suppported for db2, mysql, oracle, and sqlserver. This setting will be ignored if extLibVolume.configMapName is specified. | Default value true |
|          | driverVersion | Version of JDBC driver to fetch from well-known location.  This value is optional.  If not specified, the latest jdbc driver for the database type will be fetched. | |
|          | createDatabase | Automatically create a MySQL 8.0 Database | Default is false |
|          | dbVolume.storageClassName | If createDatasbase equals "true", specifies the name of the storageclass to use. | |
|          | dbVolume.size | If createDatasbase equals "true", specifies the size of the persistent volume used by the database. | |
| secureConnections  | required | Specify whether DevOps Deploy server connections are required to be secure | Default value is "true" |
|                    | tlsSecret | Name of Kubernetes TLS secret that contains the signed certificate for the Deploy server | |
| secret | name | Kubernetes secret which defines required DevOps Deploy passwords. | You may leave this blank to use default name of HelmReleaseName-secrets where HelmReleaseName is the name of your Helm Release/UcdServer CR, otherwise specify the secret name here.  If name is left blank and HelReleaseName-secrets does not exist in the namepace, then a default secret will be automatically created with randomized values for the passwords. |
| license | accept | Set to true to indicate you have read and agree to license agreements : https://ibm.biz/devops-deploy-license | false |
|  | serverURL | Information required to connect to the DevOps Deploy license server. | Empty (default) to begin a 60-day evaluation license period.|
| statefulset | annotations | Annotations for statefulset | Default value is "" |
|             | topologySpreadConstraints.enabled | Determines if topologySpreadConstraints are defined for the agent statefulset | Default value is false |
|             | topologySpreadConstraints.maxSkew | Describes the degree to which Pods may be unevenly distributed | Default value is 1 |
|             | topologySpreadConstraints.topologyKey | The key of node labels. Nodes that have a label with this key and identical values are considered to be in the same topology. | Default value is "kubernetes.io/arch" |
|             | topologySpreadConstraints.whenUnsatisfiable | Indicates how to deal with a Pod if it doesn't satisfy the spread constraint. | Default value is ScheduleAnyway |
| persistence | enabled | Determines if persistent storage will be used to hold the DevOps Deploy server appdata directory contents. This should always be true to preserve server data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "false" |
|             | fsGroup | The group ID to use to access persistent volumes | Default value "1001" |
| extLibVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the extlib directory is created by the chart. | Default value is "ext-lib" |
|              | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true" and existingClaimName is empty. |  |
|              | size | Size of the volume used to hold the JDBC driver .jar files.  If size is left blank and no existingClaimName is specified, then the extLib peristent volume is not created and the jdbc driver will be saved in the appDataVolume |  |
|              | existingClaimName | Persistent volume claim name for the volume that contains the JDBC driver file(s) used to connect to the DevOps Deploy database. |  |
|              | configMapName | Name of an existing ConfigMap which contains a script named script.sh. This script is run during DevOps Deploy server initialization and is useful for copying database driver .jars to the ext-lib persistent volume. |  |
|              | accessMode | Persistent storage access mode for the ext-lib persistent volume. | ReadWriteOnce |
| appDataVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the DevOps Deploy server appdata directory is created by the chart. | Default value is "appdata" |
|               | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the DevOps Deploy server appdata directory. |  |
|               | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true" and existingClaimName is empty. |  |
|               | size | Size of the volume to hold the DevOps Deploy server appdata directory. | Default is 20Gi |
|              | accessMode | Persistent storage access mode for the appdata persistent volume. | ReadWriteOnce |
| ingress | host | Host name used to access the DevOps Deploy server UI. Leave blank on OpenShift to create default route. |  |
|               | dfehost | Host name used to access the DevOps Deploy server distributed front end (DFE) UI. Leave blank on OpenShift to create default route. |  |
|               | wsshost | Host name used to access the DevOps Deploy server WSS port. Leave blank on OpenShift to create default route. |  |
|               | tlsSecret | Name of Kubernetes TLS secret containing certificate for Edge TLS termination by the ingress/route. | |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart/UcdServer CR are enabled.   | true (default) or false  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 4000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 8Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | limits.ephemeral-storage | Describes the maximum amount of ephemeral storage allowed | Default is 2Gi. See Kubernetes - [ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#setting-requests-and-limits-for-local-ephemeral-storage) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 200m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 600Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.ephemeral-storage | Describes the minimum amount of ephemeral storage required. If not specified, the amount will default to the limit (if specified) or the implementation-defined value  | Default is 500Mi. See Kubernetes - [ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#setting-requests-and-limits-for-local-ephemeral-storage) |
| javaContainerOptions | activeProcessorCount | JVM argument used to explicitly specify the number of CPU cores that the Java Virtual Machine (JVM) should consider as available. | Default is 2 |
|                      | maxRAMPercentage | Allows the Java Virtual Machine (JVM) to automatically determine the maximum heap size as a percentage of the container's allocated memory limit, rather than the total physical RAM of the host system. | Default is 70 |
| readinessProbe | initialDelaySeconds | Number of seconds after the container has started before the readiness probe is initiated | Default is 30 |
|           | periodSeconds | How often (in seconds) to perform the readiness probe | Default is 30 |
|           | failureThreshold | When a Pod starts and the probe fails, Kubernetes will try this number times before giving up. In the case of the readiness probe, the Pod will be marked Unready. | Default is 10 |
| livenessProbe | initialDelaySeconds | Number of seconds after the container has started before the liveness probe is initiated | Default is 179 |
|           | periodSeconds | How often (in seconds) to perform the liveness probe | Default is 180 |
|           | failureThreshold | When a Pod starts and the probe fails, Kubernetes will try this number times before giving up. Giving up in the case of the liveness probe means restarting the Pod. | Default is 3 |


## Storage
See the Prerequisites section of this page for storage information.

## Limitations

The Apache Derby database type is not supported when running the DevOps Deploy server in a Kubernetes cluster. This is because the containerized version is running in DevOps Deploy HA mode, which does not support Derby.
