# IBM Cloud Pak PodSecurityPolicy Definitions
The IBM Cloud Pak specification defines several pre-defined Kubernetes PodSecurityPolicy definitions.  These policies are pre-loaded on IBM Cloud platforms and are referenced by IBM Cloud Paks to describe their pod security requirements.

## Pod Security Policy Reference
The following pod security policies are available on IBM Cloud:

- [`ibm-restricted-psp`](ibm-restricted-psp.yaml)

  This policy is the most restrictive.
- [`ibm-anyuid-psp`](ibm-anyuid-psp.yaml)

  This policy allows running pods as any user with any fsgroups / supplemental group ids and volumes (excludes hostPath).   Select default docker capabilities and privilege escalation are allowed.  No sysctls or host access are allowed.

- [`ibm-anyuid-hostpath-psp`](ibm-anyuid-hostpath-psp.yaml)

  This policy allows running pods as any user with any fsgroups / supplemental group ids and all volumes.   Select default docker capabilities, privilege escalation, and safe sysctls are allowed. No unsafe systctls or host access are allowed.
- [`ibm-anyuid-hostaccess-psp`](ibm-anyuid-hostaccess-psp.yaml)

  This policy adds full host access to `ibm-anyuid-hostpath`, allowing running pods as any user with any fsgroups / supplemental group ids and all volumes.  Select default docker capabilities, privilege escalation, host access (hostIPC, hostPID, hostNetwork, hostPorts), and safe sysctls are allowed. No unsafe systctls are allowed.

- [`ibm-privileged-psp`](ibm-privileged-psp.yaml)

  This policy is the least restrictive and provides all privileged access.

## Applying IBM Cloud Pak PodSecurityContext resources to your cluster
IBM Cloud Private and IBM Cloud Kubernetes Service pre-install the IBM Cloud Pak PodSecurityContext resources on your behalf.  However, if you wish to update them to a later version or on a non-IBM Kubernetes cluster, you can the steps in this section.

To apply the IBM Cloud Pak PodSecurityContext resources to your cluster:
1.  Install the [Kubernetes command line interface (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2.  Install any other command-line utilities your Kubernetes distribution requires.
3.  Login to your cluster as a cluster administrator.  This step varies by Kubernetes distribution:
    1.  For IBM Cloud Private, use [`cloudctl login`](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/cli_commands.html#login)
    2.  For IBM Cloud Kubernetes Service, use the [`ibmcloud`](https://cloud.ibm.com/docs/containers/cs_cli_install.html) CLI.
4.  Clone the IBM Cloud Pak git repository: `git clone https://github.com/IBM/cloud-pak`
5.  `cd cloud-pak/spec/security/psp`
6.  Apply the specification yaml files to your cluster:  `kubectl apply -f .`

## More information
For additional information about Kubernetes pod security policies, see:  https://kubernetes.io/docs/concepts/policy/pod-security-policy/
