# Qualification YAML Specification
**Table of Contents**
- [Qualification YAML Specification](#Qualification-YAML-Specification)
  - [Qualification Section](#Qualification-Section)
  - [Prereqs Section](#Prereqs-Section)
    - [`security` Prerequisite Section](#security-Prerequisite-Section)
      - [`security.kubernetes` Prerequisite Section](#securitykubernetes-Prerequisite-Section)
      - [`security.ibmCloudPrivate` Prerequisite Section](#securityibmCloudPrivate-Prerequisite-Section)
      - [`security.openshift` Prerequisite Section](#securityopenshift-Prerequisite-Section)
    - [`k8sDistros` Prerequisite Section](#k8sDistros-Prerequisite-Section)
      - [`k8sDistros.<distro-resolver>` Prerequisite Sections](#k8sDistrosdistro-resolver-Prerequisite-Sections)
    - [`ibmCloudPrivateServices` Prerequisite Section](#ibmCloudPrivateServices-Prerequisite-Section)
      - [`ibmCloudPrivateServices.<service-resolver>` Prerequisite Sections](#ibmCloudPrivateServicesservice-resolver-Prerequisite-Sections)
    - [Prereq enforcement rules](#Prereq-enforcement-rules)
  - [Catalog Section](#Catalog-Section)
- [Examples](#Examples)
  - [IBM certified container Example, supporting ICP, OpenShift and IKS Kubernetes distros](#IBM-certified-container-Example-supporting-ICP-OpenShift-and-IKS-Kubernetes-distros)
  - [IBM certified container Example, supporting any kubernetes distro:](#IBM-certified-container-Example-supporting-any-kubernetes-distro)
  - [IBM Cloud Pak Example](#IBM-Cloud-Pak-Example)

## Qualification Section
The qualification section describes attributes related to the IBM&reg; Cloud Pak or IBM certified container status.

Key name:  `qualification`

**Fully Qualified Attribute Name**|**Type**|**Description/Specification**
-----|-----|-----
qualification.levelName|String|One of two pre-defined levels:`certified-ibm-cloud-pak`, `certified-ibm-solution-pak`
qualification.levelDescription|String|One of following pre-defined level descriptions: `IBM certified container`, `IBM Cloud Pak`
qualification.issueDate|String|The date in the format `M/YYYY` which the IBM Cloud Pak or IBM certified container was issued.
qualification.duration|String|The amount of time that the IBM Cloud Pak or IBM certified container qualification is valid.  Format is in months:  `nM`
qualification.terms|String|The terms description.

## Prereqs Section
The prerequisites section describes any components, features, configurations that are required in order to install the IBM Cloud Pak or Solution Pak.

This section is organized using indented blocks of topics that correspond to a resolver.  Each resolver uses the context of the installing process to determine a boolean outcome.  

Key name: `prereqs`

Valid topic keys include:  
* `security` - Describes any security pre-requisites.  All keys in this block are security resolvers.
* `k8sDistros` - Describes any Kubernetes distribution  pre-requisites.  All keys in this block are Kubernetes distribution resolvers.
* `ibmCloudPrivateServices` - Describes any IBM Cloud Private management service prerequisites.  All keys in this block are IBM Cloud Private service resolvers.

### `security` Prerequisite Section
This section is organized using indented blocks of products or components.
Key name: `security`

#### `security.kubernetes` Prerequisite Section
This section describes any pre-requisites for Kubernetes.  Enforcement of this rule is `uses`. 
* `kubernetes`- Describes any Kubernetes requirements.
  * `podSecurityPolicy` - Block: Describes any PodSecurityPolicy requirements (not applicable for Red Hat OpenShift).

    *Disposition:* `uses`
    * `name` - String: one of the following pre-defined PodSecurityPolicy names:
      * `ibm-restricted-psp`
      * `ibm-anyuid-psp`
      * `ibm-anyuid-hostpath-psp`
      * `ibm-anyuid-hostaccess-psp`
      * `ibm-privileged-psp`

#### `security.ibmCloudPrivate` Prerequisite Section
This section describes any pre-requisites when running on the IBM&reg; Cloud Private.  This section can be omitted if the Cloud Pak does not support IBM Cloud Private.
* `ibmCloudPrivate` - Describes any IBM Cloud Private product requirements.
  * `installerRole` - Block:  Describes the [IBM Cloud Private Role](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/user_management/assign_role.html) name required to install the IBM Cloud Pak or IBM certified container.

    *Disposition:* `uses`
    * `name` - String: one of the IBM Cloud Private roles:
      * `ClusterAdministrator` - The Cluster Administrator role
      * `Administrator` - The Administrator role of a team that includes the target namespace.
      * `Operator` - The Operator role of a team that includes the target namespace.

#### `security.openshift` Prerequisite Section
This section describes any pre-requisites when running on the Red Hat&reg; OpenShift&reg; Kubernetes distribution.  This section can be omitted if the Cloud Pak does not support OpenShift.
* `openshift`- Describes any Red Hat&reg; OpenShift&reg; requirements.
  * `securityContextConstraints` - Block: Describes any SecurityContextConstraints requirements.

    *Disposition:* `uses`
    * `name` - String: one of the following pre-defined SecurityContextConstraints names:
      * `ibm-restricted-scc`
      * `ibm-anyuid-scc`
      * `ibm-anyuid-hostpath-scc`
      * `ibm-anyuid-hostaccess-scc`
      * `ibm-privileged-scc`
      * `restricted`
      * `nonroot`
      * `anyuid`
      * `hostmount-anyuid`
      * `hostnetwork`
      * `hostaccess`
      * `privileged`      


### `k8sDistros` Prerequisite Section
This section is organized using indented blocks of Kubernetes distribution resolver objects.  Only one resolver is used.  If no resolver matches, then the default `kubernetes` resolver is used. 

Key name: `k8sDistros`

*Disposition:* `requires`

#### `k8sDistros.<distro-resolver>` Prerequisite Sections
Each Kubernetes distribution resolver key is a well known name which include:
* `kubernetes` - This is the default resolver when no other distribution can be resolved. 
* `ibmCloud` - IBM Cloud Kubernetes Service
* `ibmCloudPrivate` - IBM Cloud Private
* `openshift` - Red Hat OpenShift Container Platform
* `googleGKE` - Google Kubernetes Engine
* `azureAKS` -   Azure Kubernetes Service
* `amazonEKS` - Amazon Elastic Container Service for Kubernetes

Each distro-resolver includes the following fields:
* `<distro-resolver>`
  * `semver` - (Optional) The semantic version of the Kubernetes version(s).  See [semver.org](https://semver.org)

### `ibmCloudPrivateServices` Prerequisite Section
This section is organized using an array of Management Service resolver objects.  

Key name: `ibmCloudPrivateServices`

*Disposition:* `requires`

#### `ibmCloudPrivateServices.<service-resolver>` Prerequisite Sections
Each IBM Cloud Private Management Service resolver key is a well known service named defined in ICP.  The value specified here is typically the **primary** service of a feature that an IBM Cloud Pak or IBM certified container utilizes directly.

For a detailed list of services available in IBM Cloud Private see the [IBM Cloud Private Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2/getting_started/components.html)

Some common components include:
* `auth-idp` - The IBM Cloud Private Identity and Access Management service.
* `cert-manager` - The component that manages the lifecycle of certificates
* `logging` - The suite of logging services, including ElasticSearch and Kibana.
* `monitoring` - The suite of monitoring services, including Prometheus and Grafana.
* `nginx-ingress` - The default Ingress that's used on the ICP Proxy nodes.
* `service-catalog` - Implements the Open Service Broker API to provide service broker integration.
* `storage-gluster-fs` - The Gluster filesystem.
 
Each service-resolver includes the following fields:

`<none>`  - Reserved for future use, such as versioning.

### Prereq enforcement rules
Each prereq `resolver` has a default disposition of `true` or `false`.  That is:  Either the prerequisite is met or it is not.

Future editions of this specification will provide a way to override defaults, create policy rules and influence how to enforce the prereq dispositoins.

Each prereq resolver's disposition is enforced as follows:

| **Resolver** | **Enforcement** |
| -----|-----
| prereqs.security.kubernetes.podSecurityPolicy | uses |
| prereqs.security.ibmCloudPrivate.installerRole | uses |
| prereqs.security.openShift.securityContextConstraints | uses |
| prereqs.k8sDistros.&lt;resolver&gt; | required |
| prereqs.ibmCloudPrivateServices.&lt;resolver&gt; | required |


Where the enforcement policy is one of:
- `requires` - The installation MUST BE prohibited until the prerequisite is met.
- `uses` - The installation SHOULD BE prohibited until the prerequisite is met, or a compatible alternative is available.


## Catalog Section
The catalog section describes how this IBM Cloud Pak or IBM certified container should be displayed in a catalog.

For reference, the [IBM Global Catalog](https://console.test.cloud.ibm.com/docs/developing/get-coding/index-rscatalog.html) may be a template for future additions to this section.

This section is organized using indented blocks of topics.

Key name: `catalog`

**Fully Qualified Attribute Name**|**Type**|**Description/Specification**
-----|-----|-----
catalog.visible|boolean|If `false` this IBM Cloud Pak or IBM certified container is not displayed in the catalog.  The default is `true`


# Examples

## IBM certified container Example, supporting ICP, OpenShift and IKS Kubernetes distros
```yaml
qualification:
  levelName: "certified-ibm-cloud-pak"
  levelDescription: "IBM certified container"
  issueDate: "09/2018"
  duration: "12M"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"

# Defines any constraints that this certified container may require.
prereqs:
  security:                           # Security Resolver
    kubernetes:                       # Generic Kubernetes Security Resolver
      podSecurityPolicy:              # Uses:  Not required
        name: "ibm-restricted-psp"
    openshift:                        # RedHat OCP Resolver
      securityContextConstraints:
        name: "ibm-restricted-scc"    
    ibmCloudPrivate:                  # ICP Resolver
      installerRole:
        name: "Operator"              # The minimum role the user needs to install.

  k8sDistros:                         # Kubernetes Distributions resolver
    ibmCloud:
      semver: ">=1.11.3"
    ibmCloudPrivate:
      semver: ">=1.11.3"
    openshift:
      semver: ">=1.11.3"
```

##  IBM certified container Example, supporting any kubernetes distro:
```yaml
qualification:
  levelName: "certified-ibm-cloud-pak"
  levelDescription: "IBM certified container"
  issueDate: "03/2019"
  duration: "12M"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"
prereqs:
  security:
    kubernetes:
      podSecurityPolicy:
        name: "ibm-restricted-psp"
    openshift:
      securityContextConstraints:
        name: "ibm-restricted-scc"
    ibmCloudPrivate:
      installerRole:
        name: "ClusterAdministrator"

  k8sDistros:
    kubernetes:
      semver: ">=1.9"

ibmCloudPrivateServices:
  cert-manager: {}
  auth-idp: {}
```

## IBM Cloud Pak Example
```yaml
qualification:
  levelName: "certified-ibm-solution-pak"
  levelDescription: "IBM Cloud Pak"
  issueDate: "03/2019"
  duration: "12M"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"
prereqs:
  security:
    kubernetes:
      podSecurityPolicy:
        name: "ibm-restricted-psp"
    openshift:
      securityContextConstraints:
        name: "ibm-restricted-scc"
    ibmCloudPrivate:
      installerRole:
        name: "ClusterAdministrator"
  k8sDistros:                         # Kubernetes Distributions resolver
    ibmCloud:
      semver: ">=1.11.3"
    ibmCloudPrivate:
      semver: ">=1.11.3"
    openshift:
      semver: ">=1.11.3"
```
