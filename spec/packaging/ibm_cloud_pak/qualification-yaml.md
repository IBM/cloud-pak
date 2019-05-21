# Qualification YAML Specification
**Table of Contents**
- [Qualification YAML Specification](#qualification-yaml-specification)
  - [Qualification Section](#qualification-section)
  - [Prereqs Section](#prereqs-section)
    - [`security` Prerequisite Section](#security-prerequisite-section)
      - [`security.kubernetes` Prerequisite Section](#securitykubernetes-prerequisite-section)
      - [`security.ibmCloudPrivate` Prerequisite Section](#securityibmcloudprivate-prerequisite-section)
      - [`security.openshift` Prerequisite Section](#securityopenshift-prerequisite-section)
    - [`k8sDistros` Prerequisite Section](#k8sdistros-prerequisite-section)
      - [`k8sDistros.<distro-resolver>` Prerequisite Sections](#k8sdistrosdistro-resolver-prerequisite-sections)
    - [`ibmCloudPrivateServices` Prerequisite Section](#ibmcloudprivateservices-prerequisite-section)
      - [`ibmCloudPrivateServices.<service-resolver>` Prerequisite Sections](#ibmcloudprivateservicesservice-resolver-prerequisite-sections)
    - [Prereq enforcement rules](#prereq-enforcement-rules)
- [Examples](#examples)
  - [L1 Cloud Pak Example:](#l1-cloud-pak-example)
  - [L2 Certified IBM Cloud Pak Example:](#l2-certified-ibm-cloud-pak-example)

## Qualification Section
The qualification section describes attributes related to the IBM&reg; Cloud Pak status.

Key name:  `qualification`

**Fully Qualified Attribute Name**|**Type**|**Description/Specification**
-----|-----|-----
qualification.levelName|String|One of two pre-defined levels (more may be added later): `ibm-cloud-pak`, `certified-ibm-cloud-pak`
qualification.levelDescription|String|One of following pre-defined level descriptions: `IBM Cloud Pak`, `Certified IBM Cloud Pak`
qualification.issueDate|String|The date in the format `M/YYYY` which the Cloud Pak was issued.
qualification.duration|String|The amount of time that the Cloud Pak qualification is valid.  Format is in months:  `nM`
qualification.terms|String|The terms description.

## Prereqs Section
The prerequisites section describes any components, features, configurations that are required in order to install the IBM Cloud Pak or Solution Pak.

This section is organized using indented blocks of topics that correspond to a resolver.  Each resolver uses the context of the installing process to determine a boolean outcome.  

Key name: `prereqs`

Valid topic keys include:  
* `security` - Describes any security pre-requisites.  All keys in this block are security resolvers.
* `k8sDistros` - Describes any Kubernetes distribution  pre-requisites.  All keys in this block are Kubernetes distribution resolvers.
* `ibmCloudPrivateServices` - Describes any IBM Cloud Private management service prerequisites.  All keys in this block are IBM Cloud Private service resolvers.
* 
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
  * `installerRole` - Block:  Describes the [IBM Cloud Private Role](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/user_management/assign_role.html) name required to install the IBM Cloud Pak.

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
Each IBM Cloud Private Management Service resolver key is a well known service named defined in ICP.  The value specified here is typically the **primary** service of a feature that a Cloud Pak utilizes directly.

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


# Examples

## L1 Cloud Pak Example:
```yaml
qualification:
  levelName: "ibm-cloud-pak"
  levelDescription: "IBM Cloud Pak"
  issueDate: "09/2018"
  duration: "12M"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"

# Defines any constraints that this cloud pak may require.
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

## L2 Certified IBM Cloud Pak Example:
```yaml
qualification:
  levelName: "certified-ibm-cloud-pak"
  levelDescription: "Certified IBM Cloud Pak"
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
```

ibmCloudPrivateServices:
  cert-manager: {}
  auth-idp: {}
