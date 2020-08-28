# cloud-pak
Containers are the new fabric for cloud native applications, bringing simplicity in packaging and portability to developers. However, container images by themselves do not address key enterprise needs for production workloads.  Beyond containers and Kubernetes, enterprises need to orchestrate their production topology, and to provide management, security and governance of their applications.

IBM is addressing this need by introducing IBM Cloud Paks: Enterprise-grade container software -- built for Kubernetes -- on the IBM Cloud.  They're built with open standards and extended with integrations that can accelerate time to production at lower cost than containers alone.

IBM Cloud Paks are enterprise-grade containerized software by combining container images with enterprise capabilities for deployment in production use cases with integrations for management and lifecycle operations.  Features such as pre-configured deployments based on product expertise, rolling upgrades, rollbacks, security/vulnerability testing and integrations with management services for logging, monitoring, metering and security provide control and management of production workloads.

## Deprecation Notice

The following SecurityContextConstraints are deprecated

- ibm-restricted-scc
- ibm-anyuid-scc
- ibm-anyuid-hostpath-scc
- ibm-anyuid-hostaccess-scc
- ibm-privileged-scc

### Mitigation Plan

[Red Hat OpenShift 4.4 SCC Documentation](https://docs.openshift.com/container-platform/4.4/authentication/managing-security-context-constraints.html)

Customers should migrate to use the custom SCC provided by the workload (the existence of a custom SCC is required in the certification assesment) in place of the current `ibm-*-scc` being used.  In scenarios where a customer does not want to migrate to use the custom SCC provided by the workload, then the customer must switch to use a predefined Red Hat OpenShift SCC.  OpenShift instructions for managing SCCs can be found in the [Red Hat OpenShift 4.4 SCC Documentation](https://docs.openshift.com/container-platform/4.4/authentication/managing-security-context-constraints.html)
