# Qualification YAML Specification
The qualification.yaml file includes the following sections:  
* [qualification](#qualification-section)
* [prereq](#prereqs-section)
* [catalog](#catalog-section)

## Qualification Section
The qualification section describes attributes related to the IBM Cloud Pak status.

Key name:  `qualification`

**Fully Qualified Attribute Name**|**Type**|**Description/Specification**
-----|-----|-----
qualification.levelName|String|Value must be: `ibm-cloud-pak`
qualification.levelDescription|String|Value must be: `IBM Cloud Pak`
qualification.issueDate|String|The date in the format `M/YYYY` which the Cloud Pak was issued.
qualification.duration|String|The amount of time that the Cloud Pak qualification is valid from date of issue.  Must be no longer than 6 months.  Format is in months:  `nM`
qualification.terms|String|Value must be: `Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images`

## Prereqs Section
The prerequisites section describes any components, features, configurations that are required in order to install the IBM Cloud Pak.

This section is organized using indented blocks of topics.

Key name: `prereqs`

Valid topic keys include:  
* `security` - Describes any security pre-requisites.  All keys in this block are security categories.

### `security` Prerequisite Section
This section is organized using indented blocks of products or components.
Key name: `security`

#### `security.kubernetes` Prerequisite Section
* `kubernetes`- Describes any Kubernetes requirements.
  * `podSecurityPolicy` - Block: Describes any Pod Security Policy requirements.
    * `name` - String: one of the following pre-defined pod security policy names:
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

## Catalog Section
The catalog section describes how this IBM Cloud Pak should be displayed in a catalog.

For reference, the [IBM Global Catalog](https://console.test.cloud.ibm.com/docs/developing/get-coding/index-rscatalog.html) may be a template for future additions to this section.

This section is organized using indented blocks of topics.

Key name: `catalog`

**Fully Qualified Attribute Name**|**Type**|**Description/Specification**
-----|-----|-----
catalog.visible|boolean|If true (the default) if not present, this IBM Cloud Pak is displayed in the catalog.


# Examples

## Cloud Pak Example:
```
qualification:
  levelName: "ibm-cloud-pak"
  levelDescription: "IBM Cloud Pak"
  issueDate: "01/2019"
  duration: "6M"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"
prereqs:
  security:
    kubernetes:
      podSecurityPolicy:
        name: "ibm-restricted-psp"
    ibmCloudPrivate:
      installerRole:
        name: "Operator"
```