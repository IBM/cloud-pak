# Qualification YAML Specification
The qualification.yaml file includes the following sections:  
* [qualification](#qualification-section)
* [prereq](#prereqs-section)
* [catalog](#catalog-section)

## Qualification Section
The qualification section describes attributes related to the IBM&reg; Cloud Pak status.

Key name:  `qualification`

**Fully Qualified Attribute Name**|**Type**|**Description/Specification**
-----|-----|-----
qualification.levelName|String|One of two pre-defined levels: `ibm-cloud-pak`, `certified-ibm-cloud-pak`, `ibm-solution-pak`, `certified-ibm-solution-pak`
qualification.levelDescription|String|One of following pre-defined level descriptions: `IBM Cloud Pak`, `Certified IBM Cloud Pak`, `IBM Solution Pak`, `Certified IBM Solution Pak`
qualification.issueDate|String|The date in the format `M/YYYY` which the Cloud Pak was issued.
qualification.duration|String|The amount of time that the   Cloud Pak or Solution pak qualification is valid.  Format is in months:  `nM`
qualification.terms|String|The terms description.

## Prereqs Section
The prerequisites section describes any components, features, configurations that are required in order to install the IBM Cloud Pak or Solution Pak.

This section is organized using indented blocks of topics.

Key name: `prereqs`

Valid topic keys include:  
* `security` - Describes any security pre-requisites.  All keys in this block are security categories.

### `security` Prerequisite Section
This section is organized using indented blocks of products or components.
Key name: `security`

#### `security.kubernetes` Prerequisite Section
* `kubernetes`- Describes any Kubernetes requirements.
  * `podSecurityPolicy` - Block: Describes any PodSecurityPolicy requirements.
    * `name` - String: one of the following pre-defined PodSecurityPolicy names:
      * `ibm-restricted-psp`
      * `ibm-anyuid-psp`
      * `ibm-anyuid-hostpath-psp`
      * `ibm-anyuid-hostaccess-psp`
      * `ibm-privileged-psp`

#### `security.ibmCloudPrivate` Prerequisite Section
* `ibmCloudPrivate` - Describes any IBM Cloud Private product requirements.
  * `installerRole` - Block:  Describes the [IBM Cloud Private Role](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/user_management/assign_role.html) name required to install the IBM Cloud Pak.
    * `name` - String: one of the IBM Cloud Private roles:
      * `ClusterAdministrator` - The Cluster Administrator role
      * `Administrator` - The Administrator role of a team that includes the target namespace.
      * `Operator` - The Operator role of a team that includes the target namespace.

#### `security.openshift` Prerequisite Section
* `openshift`- Describes any Red Hat&reg; OpenShift&reg; requirements.
  * `securityContextConstraints` - Block: Describes any SecurityContextConstraints requirements.
    * `name` - String: one of the following pre-defined SecurityContextConstraints names:
      * `ibm-restricted-scc`
      * `ibm-anyuid-scc`
      * `ibm-anyuid-hostpath-scc`
      * `ibm-anyuid-hostaccess-scc`
      * `ibm-privileged-scc`

## Catalog Section
The catalog section describes how this IBM Cloud Pak or IBM Solution Pak should be displayed in a catalog.

For reference, the [IBM Global Catalog](https://console.test.cloud.ibm.com/docs/developing/get-coding/index-rscatalog.html) may be a template for future additions to this section.

This section is organized using indented blocks of topics.

Key name: `catalog`

**Fully Qualified Attribute Name**|**Type**|**Description/Specification**
-----|-----|-----
catalog.visible|boolean|If true (the default) if not present, this IBM Cloud Pak is displayed in the catalog.


# Examples

## L1 Cloud Pak Example:
```
qualification:
  levelName: "ibm-cloud-pak"
  levelDescription: "IBM Cloud Pak"
  issueDate: "09/2018"
  duration: "6M"
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
        name: "Operator"
```

## L2 Certified IBM Cloud Pak Example:
```
qualification:
  levelName: "certified-ibm-cloud-pak"
  levelDescription: "Certified IBM Cloud Pak"
  issueDate: "09/2018"
  duration: "6M"
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
```

## Certified IBM Solution Pak Example
```
qualification:
  levelName: "certified-ibm-solution-pak"
  levelDescription: "Certified IBM Solution Pak"
  issueDate: "09/2018"
  duration: "6M"
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
```

## L2 IBM Certified Cloud Pak Example (which is part of a Solution Pak):
```
qualification:
  levelName: "certified-ibm-cloud-pak"
  levelDescription: "Certified IBM Cloud Pak"
  issueDate: "09/2018"
  duration: "6M"
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
        name: "Operator"
catalog:
  visible: false
```
