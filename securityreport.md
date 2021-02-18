# Containerized Software Security Compliance

#### [What is it](#what-is-the-report)

#### [Why did IBM publish the report](#why-does-ibm-provide-the-report)

#### [Who should understand the report](#who-should-understand-the-report)

#### [How does IBM know the compliance](#how-does-ibm-know-the-compliance)

#### [Where is the report](#where-is-the-report)

#### [Principle of Least Privilege](#principle-of-least-privilege)

###### [Security Context Constraint](#run-with-the-red-hat-restricted-security-context-constraint) 

###### [Numeric USER](#all-product-containers-specify-a-numeric-user-in-their-dockerfile-or-equivalent-oci-build-file-for-container-images)

###### [Sudo](#no-product-containers-use-sudo)

### What is the report? 

The Containerized Software Security Compliance Report is a PDF file that explains the security posture of a IBM Containerized product. The report states if the given IBM product is compliant or not for several security principles for containerized software. The security principles included are IBM standards, guidelines, and best practices for delivering secure, enterprise grade Kubernetes software. 

### Why does IBM provide the report? 

The report is intended to provide IBM customers with a simple way to understand the security compliance details necessary in containerized software. IBM understands how important security transparency is critical in enterprise ready software. IBM is taking strides to make the security posture of its products transparent, known, and easily understandable by anyone. The security data reported is necessary for anyone who is running containerized software. IBM is providing this so that it is easy to discover and be upfront about the security posture of IBM Software products. 

### Who should understand the report? 

Any IT or Security Administrator should be familiar with the security principles in this report when managing a Kubernetes cluster, thus allowing developers to deploy containers. This report provides a summary of key security principles in a single user friendly readable document.   

### How does IBM know the compliance? 

All IBM containerized software goes through a process called IBM Kubernetes Certification before publishing. An overview of the process is described in this IBM Developer blog post. IBM gathers over 100 pieces of data through this certification process to hold products accountable for complying with a rigorous set of standards and best practices. This report takes a few critical security principles from certification process and externalizes it 

### Where is the report? 

The report is shipped as part of the product's Container Application Software for Enterprises (CASE). The CASE is the well defined file structure that provides packaging and metadata about the software as well as the certification and provenance 

To view the security report, follow the sample steps below. 

Using your favorite Web browser view the IBM Cloud-pak Github Case repo 

Navigate to the desired product and version (ibm-example/v1.0) 

Download the tgz file 

Extract the tgz file 

$ tar –xzvf <path to download>/ibm-example-1.0.tgz 

Cd to certificates/security folder 

$ cd ibm-example/certifications/files 

View the report with your favorite PDF viewer 

## Principle of Least Privilege
In containerized software, the follow guidance prescribes how IBM validates applications run with the least privilege as possible. 


### Run with the Red Hat restricted security context constraint

**Description:** IBM products must use the restricted security context constraint (SCC). This SCC is the default given to any ServiceAccount in the OpenShift cluster. This is the most restrictive SCC shipped with Red Hat OpenShift Container Platform.  

**Exposure/Risk:** Containers using a different SCC would allow less isolation between containers and the host machine potentially giving unwanted access.  

**Compliance Criteria:** Confirmed the pod and container specifications use the restricted SCC 

### All product containers specify a numeric USER in their dockerfile or equivalent OCI build file for container images

**Description:**  A container created without the USER field specified in the image build file could run as the root user. 

**Exposure/Risk:** The container could be running with root access on the host machine. The specific access granted is determined by the definition in the security context constraint.  

**Compliance Criteria:** Confirmed the USER field is set in container build file 

### No product containers use sudo 

**Description:**  A container cannot execute commands using sudo because those commands will run on the host machine with elevated privileges.  

**Exposure/Risk:** A container using sudo commands can lead to executing commands on the host machine, depending on the security context constraint(SCC).

**Compliance Criteria:** Confirmed by checking 2 conditions: 

sysctls to use sudo is turned off in the container 

 sudo privilege escalation is NOT used in a container image(s) 

 

## Network Security and Protection

## Image Vulnerability

## Host and Container Isolation

## Data Security