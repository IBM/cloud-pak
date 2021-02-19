# **IBM Containerized Software Security Fact Sheet**

## Table of Contents

**Overview**

+ [What is the report?](#what-is-the-report)

+ [Why does IBM provide the report?](#why-does-ibm-provide-the-report)

+ [Who is the intended audience for this report?](#who-is-the-intended-audience-for-this-report)

+ [How does IBM determine the compliance?](#how-does-ibm-determine-the-compliance)

+ [Where is the report?](#where-is-the-report)

**Certification Attributes**

1 Image Vulnerability Management

+ [1.1 All product images have been scanned for vulnerabilities prior to release](#11-all-product-images-have-been-scanned-for-vulnerabilities-prior-to-release) 

2 Principle of Least Privilege

+ [2.1 Run with the Red Hat restricted security context constraint](#21-run-with-the-red-hat-restricted-security-context-constraint)

+ [2.2 All product containers specify a numeric USER in their dockerfile or equivalent OCI build file for container images](#22-all-product-containers-specify-a-numeric-user-in-their-dockerfile-or-equivalent-oci-build-file-for-container-images)

+ [2.3 No product containers use sudo](#23-no-product-containers-use-sudo)

+ [2.4 No product containers run as root](#24-no-product-containers-run-as-root)

+ [2.5 Product does not require cluster level privileges](#25-product-does-not-require-cluster-level-privileges)

3 Host and Container Isolation

+ [3.1 Product containers do not target a host IP](#31-product-containers-do-not-target-a-host-ip)

+ [3.2 Product containers do not specify a host port](#32-product-containers-do-not-specify-a-host-port)

+ [3.3 Product containers do not specify a host path to mount file or directory from host node&#39;s filesystem](#33-product-containers-do-not-specify-a-host-path-to-mount-file-or-directory-from-host-nodes-filesystem)

+ [3.4 Product containers do not enable host network access](#34-product-containers-do-not-enable-host-network-access)

+ [3.5 Product containers do not share the host process ID namespace](#35-product-containers-do-not-share-the-host-process-id-namespace)

+ [3.6 Product containers do not share the host Inter Process Communication namespace](#36-product-containers-do-not-share-the-host-inter-process-communication-namespace)

+ [3.7 SSH/remote access to containers is disabled](#37-sshremote-access-to-containers-is-disabled)

4 Network Security and Protection

+ [4.1 Product does not allow anonymous access](#41-product-does-not-allow-anonymous-access)

+ [4.2 Product provides default NetworkPolicies that limit network traffic](#42-product-provides-default-networkpolicies-that-limit-network-traffic)

5 Data Security

+ [5.1 Data encryption in transit is enabled by default using TLS 1.2](#51-data-encryption-in-transit-is-enabled-by-default-using-tls-12)

6 Audit Capability

+ [6.1 Pods are able to be identified as belonging to a product](#61-pods-are-able-to-be-identified-as-belonging-to-a-product)

7 Public Key Infrastructure (PKI) / Certificate and Key Management

+ [7.1 Support key rotation and replacement](#71-support-key-rotation-and-replacement)

+ [7.2 Certificate rotation and replacement is supported by the product](#72-certificate-rotation-and-replacement-is-supported-by-the-product)

### What is the report?

The Containerized Software Security Compliance Report is a PDF file that explains the security posture of an IBM Containerized product. The report states if the given IBM product is compliant or not with several security principles for containerized software. The security principles included are IBM standards, guidelines, and best practices for delivering secure, enterprise grade Kubernetes software.

### Why does IBM provide the report?

The report is intended to provide IBM customers with a simple way to understand the security compliance attributes in containerized software. IBM understands how important security transparency is in enterprise ready software. IBM is taking strides to make the security posture of its products transparent, known, and easily understandable by anyone. IBM is providing this so that it is easy to discover the security posture of IBM software products.

### Who is the intended audience for this report?

Any system administrator or security analyst should be familiar with the security principles in this report when managing a Kubernetes cluster, thus allowing developers to deploy containers. This report provides a summary of key security principles in a single user friendly readable document.

### How does IBM determine the compliance?

All IBM containerized software goes through a process called IBM Kubernetes Certification before publishing. An overview of the process is described in this [IBM Developer blog post](https://developer.ibm.com/blogs/the-ibm-kubernetes-certification-process/). IBM assesses over 100 attributes through this certification process to hold products accountable for complying with a rigorous set of standards and best practices. One of the attributes of IBM Kubernetes Certification is the IBM Security and Privacy by Design (SPbD) program. For more information on SPbD read [this Redbook](https://www.redbooks.ibm.com/redpapers/pdfs/redp4641.pdf), specifically pages 14-15

This report takes a few critical security principles from certification process and externalizes it.

### Where is the report?

The report is shipped as part of the product&#39;s Container Application Software for Enterprises (CASE). The CASE is the well defined file structure that provides packaging and metadata about the software as well as the certification and provenance

To view the security report, follow the steps below.

- Using your favorite Web browser view the [IBM Cloud-pak Github Case repo](https://github.com/IBM/cloud-pak/tree/master/repo/case)
- Navigate to the desired product and version (ibm-example/v1.0)
- Download the tgz file
- Extract the tgz file

_$ tar –xzvf \&lt;path to download\&gt;/ibm-example-1.0.tgz_

- Cd to certificates/security folder

_$ cd ibm-example/certifications/files_

- View the report with your favorite PDF viewer

\&lt;insert a sample document image\&gt;

# **Certification Attributes**

Each line of the security report is explained in detail below to help you understand the criteria used to determine compliance and what risks exist if a product is non-compliant.

## 1 Image Vulnerability Management

### _1.1 All product images have been scanned for vulnerabilities prior to release_

**Description:**

All product container images must be scanned with a set of approved tools before product shipment. IBM updates images as new CVEs are discovered over time. Any vulnerabilities are not resolved prior to product shipment are tracked through the [IBM Product Security Incident Response (PSIRT)](https://www.ibm.com/blogs/psirt/) process

**Compliance Criteria:**

Confirmed by reviewing scan reports from an approved tool. Common tools used include:

- Red Hat image certification
- IBM Vulnerability Advisor
- Twist lock _optionally_

## 2 Principle of Least Privilege
### _2.1 Run with the Red Hat restricted security context constraint_

**Description:**

IBM products must use the restricted [security context constraint(SCC)](https://docs.openshift.com/container-platform/4.6/authentication/managing-security-context-constraints.html). This SCC is the default given to any ServiceAccount in the OpenShift cluster. This is the most restrictive SCC shipped with Red Hat OpenShift Container Platform.

**Compliance Criteria:**

Confirmed the pod and container specifications use the restricted SCC
### _2.2 All product containers specify a numeric USER in their dockerfile or equivalent OCI build file for container images_

**Description:**   A container created without the USER field specified in the image build file could run as the root user.

**Compliance Criteria:** Confirmed the USER field is set in container build file
### _2.3 No product containers use sudo_
**Description:**

A container cannot execute commands using sudo because those commands will run on the host machine with elevated privileges.

**Compliance Criteria:**

Confirmed by checking 2 conditions:

1. sysctls to use sudo is turned off in the container
2. sudo privilege escalation is NOT used in a container image(s)
### _2.4 No product containers run as root_
**Description:**

A container should run with an [arbitrary userID](https://docs.openshift.com/container-platform/4.6/openshift_images/create-images.html#images-create-guide-openshift_create-images) to prevent collision with the host's userids in /etc/passwd. A container can run with specific id (non-restricted SCC) although arbitrary id is preferred

**Compliance Criteria:**

Confirmed that root user is disabled in the Pod and Container security context.
### _2.5 Product does not require cluster level privilege_
**Description:**

A container must limit access to only the resources required to complete the actions necessary for the application to function. The container runs within a single project/namespace **not** across namespaces and **not** modifying cluster wide resources. Any dependencies that are cluster wide resources have to be documented as pre-install steps performed by a cluster administrator. Cluster wide resources include resources like Persistent Volumes, Storage Classes, Global Secrets, Catalogs, Cluster configuration.

**Compliance Criteria:**

Confirmed there are no ClusterRoleBindings associated to the products&#39; ServiceAccounts

## 3 Host and Container Isolation
### _3.1 Product containers do not target a host IP_
**Description:**

A container cannot define hostIP as this restricts scheduling and is a privileged operation on the cluster.

**Compliance Criteria:**

Confirmed by not allowing HostIP to be set in the Pod spec definition.
### _3.2 Product containers do not specify a host port_

**Description:**

A container cannot define hostPort as this restricts scheduling and is a privileged operation on the cluster.

**Compliance Criteria:**

Confirmed by not allowing HostPort to be set in the Pod spec definition.

### _3.3 Product containers do not specify a host path to mount file or directory from host node&#39;s filesystem_

**Description:**

A container cannot enable hostPath as this required external synchronization of data across host machines and is a privileged operation on the cluster

**Compliance Criteria:**

Confirmed by not allowing HostPath to be set in the Pod spec definition.
### _3.4 Product containers do not enable host network access_

**Description:**

A container must not enable hostNetwork as it allows direct visibility to / from all network interfaces of the host and is a privileged operation on the cluster

**Compliance Criteria:**

Confirmed by not allowing HostNetwork to be set in the Pod spec definition.
### _3.5 Product containers do not share the host process ID namespace_

**Description:**

A container must not enable hostPID as it allows control of all processes running on the host machine and is a privileged operation on the cluster

**Compliance Criteria:**

Confirmed by not allowing HostPID to be set in the Pod spec definition.
### _3.6 Product containers do not share the host Inter Process Communication namespace_

**Description:**

A container must not enable hostIPC as it allows usage of IPC to interact with host processes outside the container and is considered a privileged operation

**Compliance Criteria:**

Confirmed by not allowing HostIPC to be set in the Pod spec
### _3.7 SSH/remote access to containers is disabled_

**Description:**

A container should not be treated as Virtual Machine. By enabling SSH in a container that enables a back door to the entire cluster

**Compliance Criteria:**

Confirmed that SSH and any remote access is not enabled by default

## 4 Network Security and Protection

### _4.1 Product does not allow anonymous access_

**Description:**

A container should authenticate network communication between containers and services. This includes ingress, egress and intra-cluster network flow

**Compliance Criteria:**

Confirmed that IAM or mTLS is used without anonymous access

### _4.2 Product provides default NetworkPolicies that limit network traffic_

**Description:**

A container must use Kubernetes [NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) to ensure network traffic between pods are as desired (i.e. unsolicited traffic is blocked). A NetworkPolicy is an instance specific firewall defined by the product for the cluster.


**Compliance Criteria:**

Confirmed that at least 1 NetworkPolicy resource is configured in the deployment

## 5 Data Security
### _5.1 Data encryption in transit is enabled by default using TLS 1.2_

**Description:**

A container must encrypt all data in transit to other containers or pods using TLS 1.2.

**Compliance Criteria:**

Confirmed that TLS 1.2 is used for all network traffic
### 6 Audit Capability
### _6.1 Pods are able to be identified as belonging to a product_

**Description:**

A container must use Kubernetes Labels in it resources to identify it belonging to a product. In doing this, the product and Cluster Administrators can determine all resources deployed the product.

**Compliance Criteria:**

Confirmed all containers have the following labels:

- app.kubernetes.io/name
- app.kubernetes.io/managed-by
- app.kubernetes.io/instance
- app.kubernetes.io/ownerReference
- helm.sh/chart if created by a Helm chart
## 7 Public Key Infrastructure (PKI) / Certificate and Key Management
### _7.1 Support key rotation and replacement_

**Description:**

 A container must have a process to replace and/or rotate the keys in production use for data encryption at rest.x

**Compliance Criteria:**

Automated or documented process exists for a customer to replace and/or rotate a key in production use

### _7.2 Certificate rotation and replacement is supported by the product_

**Description:**

A container must have a process in place to replace/rotate certificates if/when they become compromised or expire.

**Compliance Criteria:**

Confirmed by agreeing certificate rotation is used.