# **Containerized Software Security Compliance**

# Table of Contents

_**[Containerized Software Security Compliance 1](#_Toc64619680)**_

**[What is the report? 2](#_Toc64619681)**

**[Why does IBM provide the report? 2](#_Toc64619682)**

**[Who is the intended audience for this report? 2](#_Toc64619683)**

**[How does IBM determine the compliance? 2](#_Toc64619684)**

**[Where is the report? 2](#_Toc64619685)**

[**1 Image Vulnerability Management** 3](#_Toc64619687)

[_1.1 All product images have been scanned for vulnerabilities prior to release_ 3](#_Toc64619688)

[**2 Principle of Least Privilege** 4](#_Toc64619689)

[_2.1 Run with the Red Hat restricted security context constraint_ 4](#_Toc64619690)

[_2.2 All product containers specify a numeric USER in their dockerfile or equivalent OCI build file for container images_ 4](#_Toc64619691)

[_2.3 No product containers use sudo_ 4](#_Toc64619692)

[_2.4 No product containers run as root_ 5](#_Toc64619693)

[_2.5 Product does not require cluster level privileges_ 5](#_Toc64619694)

[**3 Host and Container Isolation** 6](#_Toc64619695)

[_3.1 Product containers do not target a host IP_ 6](#_Toc64619696)

[_3.2 Product containers do not specify a host port_ 6](#_Toc64619697)

[_3.3 Product containers do not specify a host path to mount file or directory from host node&#39;s filesystem_ 7](#_Toc64619698)

[_3.4 Product containers do not enable host network access_ 7](#_Toc64619699)

[_3.5 Product containers do not share the host process ID namespace_ 8](#_Toc64619700)

[_3.6 Product containers do not share the host Inter Process Communication namespace_ 8](#_Toc64619701)

[_3.7 SSH/remote access to containers is disabled_ 8](#_Toc64619702)

[**4 Network Security and Protection** 9](#_Toc64619703)

[_4.1 Product does not allow anonymous access_ 9](#_Toc64619704)

[_4.2 Product provides default NetworkPolicies that limit network traffic_ 9](#_Toc64619705)

[**5 Data Security** 10](#_Toc64619706)

[_5.1 Data encryption in transit is enabled by default using TLS 1.2_ 10](#_Toc64619707)

[6 Audit Capability 10](#_Toc64619708)

[_6.1 Pods are able to be identified as belonging to a product_ 10](#_Toc64619709)

[7 Public Key Infrastructure (PKI) / Certificate and Key Management 11](#_Toc64619710)

[_7.1 Support key rotation and replacement_ 11](#_Toc64619711)

[_7.2 Certificate rotation and replacement is supported by the product_ 11](#_Toc64619712)

**What is the report?**

The Containerized Software Security Compliance Report is a PDF file that explains the security posture of an IBM Containerized product. The report states if the given IBM product is compliant or not with several security principles for containerized software. The security principles included are IBM standards, guidelines, and best practices for delivering secure, enterprise grade Kubernetes software.

**Why does IBM provide the report?**

The report is intended to provide IBM customers with a simple way to understand the security compliance attributes in containerized software. IBM understands how important security transparency is in enterprise ready software. IBM is taking strides to make the security posture of its products transparent, known, and easily understandable by anyone. IBM is providing this so that it is easy to discover the security posture of IBM software products.

**Who is the intended audience for this report?**

Any system administrator or security analyst should be familiar with the security principles in this report when managing a Kubernetes cluster, thus allowing developers to deploy containers. This report provides a summary of key security principles in a single user friendly readable document.

**How does IBM determine the compliance?**

All IBM containerized software goes through a process called IBM Kubernetes Certification before publishing. An overview of the process is described in this [IBM Developer blog post](https://developer.ibm.com/blogs/the-ibm-kubernetes-certification-process/). IBM assesses over 100 attributes through this certification process to hold products accountable for complying with a rigorous set of standards and best practices. One of the attributes of IBM Kubernetes Certification is the IBM Security and Privacy by Design (SPbD) program. For more information on SPbD read this Redbook, specifically pages 14-15

This report takes a few critical security principles from certification process and externalizes it.

## Where is the report?

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

**1 Image Vulnerability Management**

### _1.1 All product images have been scanned for vulnerabilities prior to release_

###


**Description:**

All product container images must be scanned with a set of approved tools before product shipment. IBM updates images as new CVEs are discovered over time. Any vulnerabilities are not resolved prior to product shipment are tracked through the IBM PSIRT process

**Compliance Criteria:**

Confirmed by reviewing scan reports from an approved tool. Common tools used include:

- Red Hat image certification
- IBM Vulnerability Advisor
- Twist lock _optionally_

**2 Principle of Least Privilege**

### _2.1 Run with the Red Hat restricted security context constraint_

**Description:**

IBM products must use the restricted [security context constraint](https://docs.openshift.com/container-platform/4.6/authentication/managing-security-context-constraints.html) (SCC). This SCC is the default given to any ServiceAccount in the OpenShift cluster. This is the most restrictive SCC shipped with Red Hat OpenShift Container Platform.

**Exposure/Risk:**

Containers using a different SCC could allow less isolation between containers and the host machine potentially giving unwanted access.

**Compliance Criteria:**

Confirmed the pod and container specifications use the restricted SCC

###


### _2.2 All product containers specify a numeric USER in their dockerfile or equivalent OCI build file for container images_

###


**Description:**   A container created without the USER field specified in the image build file could run as the root user.

**Exposure/Risk:** The container could be running with root access on the host machine. The specific access granted is determined by the definition in the security context constraint.

**Compliance Criteria:** Confirmed the USER field is set in container build file

###


### _2.3 No product containers use sudo_

###


**Description:**

A container cannot execute commands using sudo because those commands will run on the host machine with elevated privileges.

**Exposure/Risk:**

A container using sudo commands can lead to executing commands on the host machine, depending on the security context constraint(SCC).

**Compliance Criteria:**

Confirmed by checking 2 conditions:

1. sysctls to use sudo is turned off in the container
2. sudo privilege escalation is NOT used in a container image(s)

###


###


### _2.4 No product containers run as root_

###


**Description:**

A container should run with an [arbitrary](https://docs.openshift.com/container-platform/4.6/openshift_images/create-images.html#images-create-guide-openshift_create-images)[userID](https://docs.openshift.com/container-platform/4.6/openshift_images/create-images.html#images-create-guide-openshift_create-images) to prevent collision with the host&#39;s userids in /etc/passwd. A container can run with specific id (non-restricted SCC) although arbitrary id is preferred

**Exposure/Risk:**

A container that is running as root can access the host machine as well as allow other running process on the host machine to view data in the container.

**Compliance Criteria:**

Confirmed that root user is disabled in the Pod and Container security context.

###


### _2.5 Product does not require cluster level privileges_

###


**Description:**

A container must limit access to only the resources required to complete the actions necessary for the application to function. The container runs within a single project/namespace **not** across namespaces and **not** modifying cluster wide resources. Any dependencies that are cluster wide resources have to be documented as pre-install steps performed by a cluster administrator. Cluster wide resources include resources like Persistent Volumes, Storage Classes, Global Secrets, Catalogs, Cluster configuration.

**Exposure/Risk:**

A container with cluster level privileges could modify and/or view cluster wide resources potentially impacting other applications running in the cluster.

**Compliance Criteria:**

Confirmed there are no ClusterRoleBindings associated to the products&#39; ServiceAccounts

**3 Host and Container Isolation**

### _3.1 Product containers do not target a host IP_

###


**Description:**

A container cannot define hostIP as this restricts scheduling and is a privileged operation on the cluster.

**Exposure/Risk:**

The container would never get into &quot;Running&quot; state unless the host machine had the IP address defined in the pod

**Compliance Criteria:**

Confirmed by not allowing HostIP to be set in the Pod spec definition.

###


### _3.2 Product containers do not specify a host port_

**Description:**

A container cannot define hostPort as this restricts scheduling and is a privileged operation on the cluster.

**Exposure/Risk:**

Host communication and access can introduce scheduling conflicts, different behavior based on node filesystem, visibility / impact to processes running on the host, and communication with processes outside the container.

**Compliance Criteria:**

Confirmed by not allowing HostPort to be set in the Pod spec definition.

### _3.3 Product containers do not specify a host path to mount file or directory from host node&#39;s filesystem_

###


**Description:**

A container cannot enable hostPath as this required external synchronization of data across host machines and is a privileged operation on the cluster

**Exposure/Risk:**

The container would be able to access the host filesystem with permissions grant in the associated SCC

**Compliance Criteria:**

Confirmed by not allowing HostPath to be set in the Pod spec definition.

###


### _3.4 Product containers do not enable host network access_

###


**Description:**

A container must not enable hostNetwork as it allows direct visibility to / from all network interfaces of the host and is a privileged operation on the cluster

**Exposure/Risk:**

The container would be able to access the host network interfaces potentially sniffing the traffic

**Compliance Criteria:**

Confirmed by not allowing HostNetwork to be set in the Pod spec definition.

###


### _3.5 Product containers do not share the host process ID namespace_

**Description:**

A container must not enable hostPID as it allows control of all processes running on the host machine and is a privileged operation on the cluster

**Exposure/Risk:**

The container would be able to control any process on the host machine

**Compliance Criteria:**

Confirmed by not allowing HostPID to be set in the Pod spec definition.

### _3.6 Product containers do not share the host Inter Process Communication namespace_

###


**Description:**

A container must not enable hostIPC as it allows usage of IPC to interact with host processes outside the container and is considered a privileged operation

**Exposure/Risk:**

The container would be able to control all IPC mechanisms such as pipes, sockets on the host machine.

**Compliance Criteria:**

Confirmed by not allowing HostIPC to be set in the Pod spec

### _3.7 SSH/remote access to containers is disabled_

###


**Description:**

A container should not be treated as Virtual Machine. By enabling SSH in a container that enables a back door to the entire cluster

**Exposure/Risk:**

The container would be granted full control of the entire cluster

**Compliance Criteria:**

Confirmed that SSH and any remote access is not enabled by default

**4 Network Security and Protection**

### _4.1 Product does not allow anonymous access_

###


**Description:**

A container should authenticate network communication between containers and services. This includes ingress, egress and intra-cluster network flow

**Exposure/Risk:**

The container services could be accessed by an unauthorized cluster user potentially obtaining confidential data

**Compliance Criteria:**

Confirmed that IAM or mTLS is used without anonymous access

### _4.2 Product provides default NetworkPolicies that limit network traffic_

###


**Description:**

A container must use Kubernetes [NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) to ensure network traffic between pods are as desired (i.e. unsolicited traffic is blocked). A NetworkPolicy is an instance specific firewall defined by the product for the cluster.

**Exposure/Risk:**

The container could be taken down from a Distributed Denial-of-Service (DDoS) network attack. Without a NetworkPolicy, the container is similar to running on a server without any firewall rules

**Compliance Criteria:**

Confirmed that at least 1 NetworkPolicy resource is configured in the deployment

**5 Data Security**

### _5.1 Data encryption in transit is enabled by default using TLS 1.2_

**Description:**

A container must encrypt all data in transit to other containers or pods using TLS 1.2.

**Exposure/Risk:**

The container would be exposing its data to other cluster users if not encrypted

**Compliance Criteria:**

Confirmed that TLS 1.2 is used for all network traffic

###


### 6 Audit Capability

### _6.1 Pods are able to be identified as belonging to a product_

###


**Description:**

A container must use Kubernetes Labels in it resources to identify it belonging to a product. In doing this, the product and Cluster Administrators can determine all resources deployed the product.

**Exposure/Risk:**

Any container not labeled would make it impossible for a Cluster Administrator to identify Kubernetes resources belonging to running applications. All of these Kubernetes resources are consuming cluster CPU/RAM and would be difficult to know when is needed if not labeled properly.

**Compliance Criteria:**

Confirmed all containers have the following labels:

- app.kubernetes.io/name
- app.kubernetes.io/managed-by
- app.kubernetes.io/instance
- app.kubernetes.io/ownerReference
- helm.sh/chart if created by a Helm chart

###


### 7 Public Key Infrastructure (PKI) / Certificate and Key Management

### _7.1 Support key rotation and replacement_

###


**Description:**

 A container must have a process to replace and/or rotate the keys in production use for data encryption at rest.

**Exposure/Risk:**

A container with a key provided by the product would be limiting the customers ability to protect their own data

**Compliance Criteria:**

Automated or documented process exists for a customer to replace and/or rotate a key in production use

###


###


### _7.2 Certificate rotation and replacement is supported by the product_

###


**Description:**

A container must have a process in place to replace/rotate certificates if/when they become compromised or expire.

**Exposure/Risk:**

A container without a built in certificate rotation process would be exposed to hacking when the certificate is compromised or not be able to update when it expires

**Compliance Criteria:**

Confirmed by agreeing certificate rotation is used.