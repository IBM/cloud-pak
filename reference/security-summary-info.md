**IBM Containerized Software Security Summary**
<!-- TOC insertAnchor:true -->

- [Overview](#overview)
  - [What is the Security Summary?](#what-is-the-security-summary)
  - [Why does IBM provide these summaries?](#why-does-ibm-provide-these-summaries)
  - [Who is the intended audience?](#who-is-the-intended-audience)
  - [How does IBM determine the compliance?](#how-does-ibm-determine-the-compliance)
  - [Where is the summary?](#where-is-the-summary)
- [Certification Metrics](#certification-metrics)
  - [1. Image Vulnerability Management](#1-image-vulnerability-management)
    - [_1.1 All product images have been scanned for vulnerabilities prior to release_](#11-all-product-images-have-been-scanned-for-vulnerabilities-prior-to-release)
  - [2. Principle of Least Privilege](#2-principle-of-least-privilege)
    - [_2.1 Run with the Red Hat restricted security context constraint(automated)_](#21-run-with-the-red-hat-restricted-security-context-constraintautomated)
    - [_2.2 All product containers specify a numeric USER in their Dockerfile or equivalent OCI build file for container images_](#22-all-product-containers-specify-a-numeric-user-in-their-dockerfile-or-equivalent-oci-build-file-for-container-images)
    - [_2.3 No product containers use sudo_](#23-no-product-containers-use-sudo)
    - [_2.4 No product containers run as root_](#24-no-product-containers-run-as-root)
  - [3. Host and Container Isolation](#3-host-and-container-isolation)
    - [_3.1 Product containers do not target a host IP(automated)_](#31-product-containers-do-not-target-a-host-ipautomated)
    - [_3.2 Product containers do not specify a host port(automated)_](#32-product-containers-do-not-specify-a-host-portautomated)
    - [_3.3 Product containers do not specify a host path to mount file or directory from host node's filesystem(automated)_](#33-product-containers-do-not-specify-a-host-path-to-mount-file-or-directory-from-host-nodes-filesystemautomated)
    - [_3.4 Product containers do not enable host network access(automated)_](#34-product-containers-do-not-enable-host-network-accessautomated)
    - [_3.5 Product containers do not share the host process ID namespace(automated)_](#35-product-containers-do-not-share-the-host-process-id-namespaceautomated)
    - [_3.6 Product containers do not share the host Inter Process Communication namespace(automated)_](#36-product-containers-do-not-share-the-host-inter-process-communication-namespaceautomated)
    - [_3.7 SSH/remote access to containers is disabled_](#37-sshremote-access-to-containers-is-disabled)
  - [4. Network Security and Protection](#4-network-security-and-protection)
    - [_4.1 Product does not allow anonymous access_](#41-product-does-not-allow-anonymous-access)
    - [_4.2 Product provides default NetworkPolicies that limit network traffic_](#42-product-provides-default-networkpolicies-that-limit-network-traffic)
  - [5. Data Security](#5-data-security)
    - [_5.1 Data encryption in transit is enabled by default using TLS 1.2_](#51-data-encryption-in-transit-is-enabled-by-default-using-tls-12)
  - [6. Audit Capability](#6-audit-capability)
    - [_6.1 Pods are able to be identified as belonging to a product(automated)_](#61-pods-are-able-to-be-identified-as-belonging-to-a-productautomated)
  - [7. Key and Certificate Management](#7-key-and-certificate-management)
    - [_7.1 Support key rotation and replacement_](#71-support-key-rotation-and-replacement)
    - [_7.2 Certificate rotation and replacement is supported by the product_](#72-certificate-rotation-and-replacement-is-supported-by-the-product)

<!-- /TOC -->

<a id="markdown-overview" name="overview"></a>

## Overview

<a id="markdown-what-is-the-security-summary" name="what-is-the-security-summary"></a>

### What is the Security Summary?

The Security Summary is a PDF file that explains the security posture of an IBM Containerized product. The summary indicates compliance with several IBM Certification security metrics. The security metrics included are based on IBM standards, guidelines, and best practices for delivering secure, enterprise grade software for Red Hat&reg; OpenShift&reg; Container Platform.

<a id="markdown-why-does-ibm-provide-these-summaries" name="why-does-ibm-provide-these-summaries"></a>

### Why does IBM provide these summaries?

The Security Summary provides IBM customers with a simple way to understand the product's software posture before deployment. The summary helps IBM make the security posture of its products transparent, known, and easily understandable.

<a id="markdown-who-is-the-intended-audience" name="who-is-the-intended-audience"></a>

### Who is the intended audience?

The summary is intended for OpenShift Container Platform system and application administrators, and security professionals who deploy, plan to deploy, evaluate, or secure container workloads in a cluster.  These metrics can be used to apply the appropriate controls and configurations to the OpenShift Container Platform cluster and topology to protect workloads and provide secure access.  

<a id="markdown-how-does-ibm-determine-the-compliance" name="how-does-ibm-determine-the-compliance"></a>

### How does IBM determine the compliance?

All IBM containerized software goes through a process that is called IBM Certification before publishing. An overview of the process is described in this [IBM Developer blog post](https://developer.ibm.com/blogs/the-ibm-kubernetes-certification-process/). IBM assesses over 100 metrics through this certification process to measure and ensure compliance with a rigorous set of standards and best practices. One of the attributes of IBM Certification is the IBM Security and Privacy by Design (SPbD) program. For more information on SPbD, see [Security in Development](https://www.ibm.com/trust/security-spbd). This summary takes a few critical security metrics from the certification process and externalizes it. Through that process some of the metrics are automated in the continuous integration and delivery pipeline while others are verified with documentation. The attributes with "automated" in their name are validated by an IBM internal linter tool.

<a id="markdown-where-is-the-summary" name="where-is-the-summary"></a>

### Where is the summary?

The summary is shipped as part of the product's [Container Application Software for Enterprises (CASE)](https://github.com/IBM/case). A CASE is a well-defined file structure that provides packaging and metadata about the software, including its certification state and provenance.

To view the Security Summary, follow the steps below:

1. Browse to [IBM Cloud-pak GitHub Case repo](https://github.com/IBM/cloud-pak/tree/master/repo/case).
2. Browse to the desired product and version (ibm-example/v1.0).
3. Download the tgz file.
4. Extract the tgz file.  For example:

    `$ tar –xzvf <\download-location>/ibm-example-1.0.tgz`

5. Change the working directory to the `certificates/security` folder.  For example:

    `$ cd ibm-example/certifications/security`

6. View the summary with your PDF viewer

<a id="markdown-certification-metrics" name="certification-metrics"></a>

## Certification Metrics

Each line of the Security Summary is explained in detail below to help you understand the criteria that are used to determine compliance.

<a id="markdown-1-image-vulnerability-management" name="1-image-vulnerability-management"></a>

### 1. Image Vulnerability Management

Image vulnerability management consists of security metrics for security vulnerabilities that are found in the packaged images.

<a id="markdown-_11-all-product-images-have-been-scanned-for-vulnerabilities-prior-to-release_" name="_11-all-product-images-have-been-scanned-for-vulnerabilities-prior-to-release_"></a>

#### _1.1 All product images have been scanned for vulnerabilities prior to release_

**Description:**

All product container images must be scanned with a set of approved tools before product shipment. IBM updates images as new [Common Vulnerabilities and Exposures (CVE)](https://cve.mitre.org/) are discovered over time. Any vulnerabilities not resolved before product shipment are tracked through the [IBM Product Security Incident Response (PSIRT)](https://www.ibm.com/blogs/psirt/) process.

**Acceptance Criteria:**

Confirmed by reviewing scan reports from an approved tool. Common tools that are used include:

- Red Hat image certification
- IBM Vulnerability Advisor

<a id="markdown-2-principle-of-least-privilege" name="2-principle-of-least-privilege"></a>

### 2. Principle of Least Privilege

Principle of least privilege consists of security metrics ensuring products run with the fewest privileges necessary.

<a id="markdown-_21-run-with-the-red-hat-restricted-security-context-constraintautomated_" name="_21-run-with-the-red-hat-restricted-security-context-constraintautomated_"></a>

#### _2.1 Run with the Red Hat restricted security context constraint(automated)_

**Description:**

IBM products must use the restricted [security context constraint(SCC)](https://docs.openshift.com/container-platform/4.6/authentication/managing-security-context-constraints.html). This SCC is the default given to any ServiceAccount in a cluster. This is the most restrictive SCC shipped with Red Hat&reg; OpenShift&reg; Container Platform.

**Acceptance Criteria:**

Confirmed the pod and container specifications use the restricted SCC

<a id="markdown-_22-all-product-containers-specify-a-numeric-user-in-their-dockerfile-or-equivalent-oci-build-file-for-container-images_" name="_22-all-product-containers-specify-a-numeric-user-in-their-dockerfile-or-equivalent-oci-build-file-for-container-images_"></a>

#### _2.2 All product containers specify a numeric USER in their Dockerfile or equivalent OCI build file for container images_

**Description:**   A container that is created without the USER field specified in the image build file could run as the root user.

**Acceptance Criteria:**

Confirmed the USER field is set in container build file

<a id="markdown-_23-no-product-containers-use-sudo_" name="_23-no-product-containers-use-sudo_"></a>

#### _2.3 No product containers use sudo_

**Description:**

A container cannot execute commands using ``sudo`` because those commands will run with elevated privileges.

**Acceptance Criteria:**

Confirmed by checking 3 conditions:

1. sysctls to use ``sudo`` is turned off in the container
2. ``sudo`` privilege escalation is NOT used in a container image(s)

<a id="markdown-_24-no-product-containers-run-as-root_" name="_24-no-product-containers-run-as-root_"></a>

#### _2.4 No product containers run as root_

**Description:**

A container must run with an [arbitrary userID](https://docs.openshift.com/container-platform/4.6/openshift_images/create-images.html#images-create-guide-openshift_create-images) to prevent collision on the host machine. A container can run with specific id (non-restricted SCC) although arbitrary id is preferred.

**Acceptance Criteria:**

Confirmed that root user is disabled in the Pod and Container security context.

<a id="markdown-3-host-and-container-isolation" name="3-host-and-container-isolation"></a>

### 3. Host and Container Isolation

Host and container isolation consists of security principles to maintain the running container does **not** have access to modify the host machine.

<a id="markdown-_31-product-containers-do-not-target-a-host-ipautomated_" name="_31-product-containers-do-not-target-a-host-ipautomated_"></a>

#### _3.1 Product containers do not target a host IP(automated)_

**Description:**

A container cannot define ``hostIP`` as this restricts scheduling and is a privileged operation on the cluster.

**Acceptance Criteria:**

Confirmed by not allowing ``HostIP`` to be set in the Pod spec definition.

<a id="markdown-_32-product-containers-do-not-specify-a-host-portautomated_" name="_32-product-containers-do-not-specify-a-host-portautomated_"></a>

#### _3.2 Product containers do not specify a host port(automated)_

**Description:**

A container cannot define ``hostPort`` as this restricts scheduling and is a privileged operation on the cluster.

**Acceptance Criteria:**

Confirmed by not allowing ``HostPort`` to be set in the Pod spec definition.

<a id="markdown-_33-product-containers-do-not-specify-a-host-path-to-mount-file-or-directory-from-host-nodes-filesystemautomated_" name="_33-product-containers-do-not-specify-a-host-path-to-mount-file-or-directory-from-host-nodes-filesystemautomated_"></a>

#### _3.3 Product containers do not specify a host path to mount file or directory from host node's filesystem(automated)_

**Description:**

A container cannot enable ``hostPath`` as this required external synchronization of data across host machines and is a privileged operation on the cluster.

**Acceptance Criteria:**

Confirmed by not allowing ``HostPath`` to be set in the Pod spec definition.

<a id="markdown-_34-product-containers-do-not-enable-host-network-accessautomated_" name="_34-product-containers-do-not-enable-host-network-accessautomated_"></a>

#### _3.4 Product containers do not enable host network access(automated)_

**Description:**

A container must not enable ``hostNetwork`` as it allows direct visibility to / from all network interfaces of the host and is a privileged operation on the cluster.

**Acceptance Criteria:**

Confirmed by not allowing ``HostNetwork`` to be set in the Pod spec definition.

<a id="markdown-_35-product-containers-do-not-share-the-host-process-id-namespaceautomated_" name="_35-product-containers-do-not-share-the-host-process-id-namespaceautomated_"></a>

#### _3.5 Product containers do not share the host process ID namespace(automated)_

**Description:**

A container must not enable ``hostPID`` as it allows control of all processes running on the host machine and is a privileged operation on the cluster.

**Acceptance Criteria:**

Confirmed by not allowing ``HostPID`` to be set in the Pod spec definition.

<a id="markdown-_36-product-containers-do-not-share-the-host-inter-process-communication-namespaceautomated_" name="_36-product-containers-do-not-share-the-host-inter-process-communication-namespaceautomated_"></a>

#### _3.6 Product containers do not share the host Inter Process Communication namespace(automated)_

**Description:**

A container must not enable ``hostIPC`` as it allows usage of IPC to interact with host processes outside the container and is considered a privileged operation.

**Acceptance Criteria:**

Confirmed by not allowing ``HostIPC`` to be set in the Pod spec

<a id="markdown-_37-sshremote-access-to-containers-is-disabled_" name="_37-sshremote-access-to-containers-is-disabled_"></a>

#### _3.7 SSH/remote access to containers is disabled_

**Description:**

A container should not be treated as Virtual Machine. By enabling SSH in a container that enables a back door to the entire cluster.

**Acceptance Criteria:**

Confirmed that SSH and any remote access is not enabled by default

<a id="markdown-4-network-security-and-protection" name="4-network-security-and-protection"></a>

### 4. Network Security and Protection

Network security and protection consists of security metrics necessary to isolate and secure network traffic.

<a id="markdown-_41-product-does-not-allow-anonymous-access_" name="_41-product-does-not-allow-anonymous-access_"></a>

#### _4.1 Product does not allow anonymous access_

**Description:**

A container must authenticate network communication between containers and services. This includes ingress, egress, and intra-cluster network flow.

**Acceptance Criteria:**

Confirmed that IAM or mTLS is used without anonymous access

<a id="markdown-_42-product-provides-default-networkpolicies-that-limit-network-traffic_" name="_42-product-provides-default-networkpolicies-that-limit-network-traffic_"></a>

#### _4.2 Product provides default NetworkPolicies that limit network traffic_

**Description:**

A containerized software product must use Kubernetes [NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) to ensure that network traffic between pods are as desired (that is, unsolicited traffic is blocked). A NetworkPolicy is an instance specific firewall that is defined by the product for the cluster.

**Acceptance Criteria:**

Confirmed that at least 1 NetworkPolicy resource is configured in the deployment

<a id="markdown-5-data-security" name="5-data-security"></a>

### 5. Data Security

Data security consists of security metrics that ensure data is accessible only as required for product functionality.

<a id="markdown-_51-data-encryption-in-transit-is-enabled-by-default-using-tls-12_" name="_51-data-encryption-in-transit-is-enabled-by-default-using-tls-12_"></a>

#### _5.1 Data encryption in transit is enabled by default using TLS 1.2_

**Description:**

A container must encrypt all data in transit to other containers or pods using TLS 1.2.

**Acceptance Criteria:**

Confirmed that TLS 1.2 is used for all network traffic

<a id="markdown-6-audit-capability" name="6-audit-capability"></a>

### 6. Audit Capability

Audit capability consists of security metrics for auditing and accountability for the product

<a id="markdown-_61-pods-are-able-to-be-identified-as-belonging-to-a-productautomated_" name="_61-pods-are-able-to-be-identified-as-belonging-to-a-productautomated_"></a>

#### _6.1 Pods are able to be identified as belonging to a product(automated)_

**Description:**

A container must use Kubernetes Labels in the resources to identify they belong to a product. The labels can be used by the product and Cluster Administrators to determine all resources deployed with the product.

**Acceptance Criteria:**

Confirmed that all containers have the following labels:

- app.kubernetes.io/name
- app.kubernetes.io/managed-by
- app.kubernetes.io/instance
- app.kubernetes.io/ownerReference
- helm.sh/chart if created by a Helm chart

<a id="markdown-7-key-and-certificate-management" name="7-key-and-certificate-management"></a>

### 7. Key and Certificate Management

Key and certification management consists of security metrics to secure and manage the certificate lifecycle.

<a id="markdown-_71-support-key-rotation-and-replacement_" name="_71-support-key-rotation-and-replacement_"></a>

#### _7.1 Support key rotation and replacement_

**Description:**

 A container must have a process to replace and/or rotate the keys in production use for data encryption at rest.

**Acceptance Criteria:**

Automated or documented process exists for a customer to replace and/or rotate a key in production use

<a id="markdown-_72-certificate-rotation-and-replacement-is-supported-by-the-product_" name="_72-certificate-rotation-and-replacement-is-supported-by-the-product_"></a>

#### _7.2 Certificate rotation and replacement is supported by the product_

**Description:**

A container must have a process in place to replace/rotate certificates if/when they become compromised or expire.

**Acceptance Criteria:**

Automated or documented process exists for a customer to replace and/or rotate a certificate in production use
