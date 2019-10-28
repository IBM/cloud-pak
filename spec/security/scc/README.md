# IBM Cloud Pak SecurityContextConstraints Definitions
The IBM Cloud Pak specification defines several pre-defined Red Hat&reg; OpenShift&reg; SecurityContextConstraints (SCC) definitions.  These definitions are referenced by IBM Cloud Paks to describe their pod security requirements for Red Hat OpenShift environments and include both the Red Hat OpenShift pre-defined SCC's and additional SCC's (prefixed by `ibm-`) for compatiblity with the [IBM Cloud Pak PodSecurityPolicy definitions](../psp/README.md).


## SecurityContextConstraint Reference

The following 7 SecurityContextConstraints are pre-installed on Red Hat OpenShift and are __not__ compatible with [IBM Cloud Pak PodSecurityPolicy definitions](../psp/README.md) unless otherwise noted:

- `restricted`

   This constraint denies access to all host features and requires pods to be run with a UID, and SELinux context that are allocated to the namespace.  This is the most restrictive SCC and it is used by default for authenticated users.
- `nonroot`

   This constraint provides all features of the restricted SCC but allows users to run with any non-root UID.  The user must specify the UID or it must be specified on the by the manifest of the container runtime.
- `anyuid`

   This constraint provides all features of the restricted SCC but allows users to run with any UID and any GID.
- `hostmount-anyuid`

   This constraint provides all the features of the restricted SCC but allows host mounts and any UID by a pod.  This is primarily used by the persistent volume recycler. WARNING: this SCC allows host file system access as any UID, including UID 0.  Grant with caution.

- `hostnetwork`

   This constraint allows using host networking and host ports but still requires pods to be run with a UID and SELinux context that are allocated to the namespace.
- `hostaccess`

   This constraint allows access to all host namespaces but still requires pods to be run with a UID and SELinux context that are allocated to the namespace. WARNING: this SCC allows host access to namespaces, file systems, and PIDS.  It should only be used by trusted pods.  Grant with caution.
- `privileged`

   This constraint allows access to all privileged and hostfeatures and the ability to run as any user, any group, any fsGroup, and with any SELinux context.  WARNING: this is the most relaxed SCC and should be used only for cluster administration. Grant with caution.

  This constraint is compatible with the `ibm-privileged-scc` constraint.


The following 5 SecurityContextConstraints are available on IBM Cloud Private on Red Hat OpenShift and are compatible with [IBM Cloud Pak PodSecurityPolicy definitions](../psp/README.md) unless otherwise noted::

- [`ibm-restricted-scc`](ibm-restricted-scc.yaml)

  This constraint is the most restrictive and is compatible with the `ibm-restricted-psp` PodSecurityPolicy when applied to OpenShift 3.11 or later.  On earlier versions of OpenShift, these values use incompatible defaults.  Pods must avoid using these features with this SCC, or use a less restrictive SCC such as the `restricted` policy, which uses the default values.  See the [OpenShift 3.11 release notes](https://docs.openshift.com/container-platform/3.11/release_notes/ocp_3_11_release_notes.html) for details about these options.
  - allowPrivilegeEscalation: defaults to `true`
  - defaultPrivilegeEscalation: defaults to `true`
  - forbiddenSysctls: defaults to null, allowing all safe sysctls
  - allowedUnsafeSysctls: defaults to disable all unsafe sysctls
  
  This constraint differs from the `restricted` SCC in the following ways:
  - Any User ID can be specified.
  - Group ID ranges are limited to the ranges allowed by SCCs and are not determined by the namespace (project).
  - All capabilities are dropped.


- [`ibm-anyuid-scc`](ibm-anyuid-scc.yaml)

  This constraint allows running pods as any user with any fsgroups / supplemental group ids and volumes (excludes hostPath).   Select default docker capabilities and privilege escalation are allowed.  No sysctls or host access are allowed.

  This constraint is compatible with the `ibm-anyuid-psp` PodSecurityPolicy when applied to OpenShift 3.11 or later.  On earlier versions of OpenShift, these values use incompatible defaults.  Pods must avoid using these features with this SCC, or use the `anyuid` or less restrictive SCC, which uses the default values.  See the [OpenShift 3.11 release notes](https://docs.openshift.com/container-platform/3.11/release_notes/ocp_3_11_release_notes.html) for details about these options.
  - forbiddenSysctls: defaults to null, allowing all safe sysctls
  - allowedUnsafeSysctls: defaults to disable all unsafe sysctls

- [`ibm-anyuid-hostpath-scc`](ibm-anyuid-hostpath-scc.yaml)

  This constraint allows running pods as any user with any fsgroups / supplemental group ids and all volumes.   Select default docker capabilities, privilege escalation, and safe sysctls are allowed. No unsafe systctls or host access are allowed.

  This constraint is compatible with the `ibm-anyuid-hostpath-psp` PodSecurityPolicy when applied to OpenShift 3.11 or later.  On earlier versions of OpenShift, these values use incompatible defaults.  Pods must avoid using these features with this SCC, or use the `hostmount-anyuid` or less restrictive SCC, which uses the default values.  See the [OpenShift 3.11 release notes](https://docs.openshift.com/container-platform/3.11/release_notes/ocp_3_11_release_notes.html) for details about these options.
  - forbiddenSysctls: defaults to null, allowing all safe sysctls
  - allowedUnsafeSysctls: defaults to disable all unsafe sysctls

- [`ibm-anyuid-hostaccess-scc`](ibm-anyuid-hostaccess-scc.yaml)

  This constraint adds full host access to `ibm-anyuid-hostpath`, allowing running pods as any user with any fsgroups / supplemental group ids and all volumes.  Select default docker capabilities, privilege escalation, host access (hostIPC, hostPID, hostNetwork, hostPorts), and safe sysctls are allowed. No unsafe systctls are allowed.

  This constraint is compatible with the `ibm-anyuid-hostaccess-psp` PodSecurityPolicy when applied to OpenShift 3.11 or later.  On earlier versions of OpenShift, these values use incompatible defaults.  Pods must avoid using these features with this SCC, or use the `hostaccess` or less restrictive SCC, which uses the default values.  See the [OpenShift 3.11 release notes](https://docs.openshift.com/container-platform/3.11/release_notes/ocp_3_11_release_notes.html) for details about these options.
  - forbiddenSysctls: defaults to null, allowing all safe sysctls
  - allowedUnsafeSysctls: defaults to disable all unsafe sysctls

- [`ibm-privileged-scc`](ibm-privileged-scc.yaml)

  This constraint is the least restrictive and provides all privileged access and is compatible with the `ibm-privileged-psp` PodSecurityPolicy and the `privileged` SCC.


## Installing IBM Cloud Pak SecurityContextConstraints resources to your cluster
To apply the IBM Cloud Pak SecurityContextConstraints resources to your cluster:
1.  Install the Red Hat [OpenShift command line interface](https://docs.openshift.com/container-platform/3.9/cli_reference/get_started_cli.html)
2.  Login to your cluster as a cluster administrator:  `oc login`
3.  Clone the IBM Cloud Pak git repository: `git clone https://github.com/IBM/cloud-pak`
4.  `cd cloud-pak/spec/security/scc`
5.  Apply the specification yaml files to your cluster:  `oc apply -f . --validate=false`

## Updating SCCs 
The following fields are updatable:
* seLinuxOptions
* volumes
* priority
* UID and GUID ranges

Note:  SecurityContextConstraints also store user and group bindings within them.  By using the `apply` command, you can later update the SCCs without accidentally removing the group and user bindings, if the user and group bindings are not explicitly  specified in the SCC yaml.

## Change Logs
### Version 1.1.0
- seLinuxContext field changed from runAsAny --> MustRunAs, in order to enforce the seLinux validation
  - This will be done in a future release 
- users field was removed, in order to preserve user bindings during a kubectl apply
- priorities were removed because these should be a customer specific setting
- ibm-hostpath and ibm-hostaccess: forbiddenSysctls changed from '*' --> [].  This error was noticed and corrected.
- Fixed typo: defaultPrivilegeEscalation --> defaultAllowPrivilegeEscalation

## More information
For additional information about Red Hat OpenShift security context constraints, see:  

- [Blog:  Understanding OpenShift Security Context Constraints](https://developers.redhat.com/blog/2016/10/21/understanding-openshift-security-context-constraints/)
- [RHOS v3.9 Doc: SCC API](https://docs.openshift.com/container-platform/3.9/rest_api/api/v1.SecurityContextConstraints.html)
- [RHOS v3.9 Doc: SCC Management Guide](https://docs.openshift.com/container-platform/3.9/admin_guide/manage_scc.html)
- [RHOS v3.9 Doc: Volume Security](https://docs.openshift.com/container-platform/3.9/install_config/persistent_storage/pod_security_context.html)
- [RHOS v3.9 Doc: Sysctls](https://docs.openshift.com/container-platform/3.9/admin_guide/sysctls.html)
- [RHOS v3.9 Doc: Seccomp](https://docs.openshift.com/container-platform/3.9/admin_guide/seccomp.html)






