# IBM Cloud Pak Pod Security Policy Definitions
The IBM Cloud Pak specification defines several pre-defined Kubernetes Pod Security Policy definitions.  These policies are pre-loaded on IBM Cloud platforms and are referenced by IBM Cloud Paks to describe their pod security requirements.

The following IBM Cloud platform versions are pre-loaded:
- IBM Cloud Private version 3.1.1
- IBM Cloud Kubernetes Service 

When the PodSecurityPolicy definitions are not pre-loaded, use the instructions in this document to install and update them into your Kubernetes cluster.

- [PodSecurityPolicy Reference](#podsecuritypolicy-reference)
- [Applying IBM Cloud Pak PodSecurityPolicy and ClusterRole resources to your cluster](#applying-ibm-cloud-pak-podsecuritypolicy-and-clusterrole-resources-to-your-cluster)
- [Applying a PodSecurityPolicy to your namespace](#applying-a-podsecuritypolicy-to-your-namespace)
- [Validating which PodSecurityPolicies are bound to a namespace](#validating-which-podsecuritypolicies-are-bound-to-a-namespace)
- [More information](#more-information)

## PodSecurityPolicy Reference
The following PodSecurityPolicies are available on to use with IBM Cloud Paks.  Each PodSecurityPolicy file includes an associated ClusterRole as indicated:

- [`ibm-restricted-psp`](ibm-restricted-psp.yaml) / [`ibm-restricted-cr`](ibm-restricted-cr.yaml)

  This policy is the most restrictive, forcing pods to declare their requirements, avoiding platform or cluster-specific configuration differences.
- [`ibm-anyuid-psp`](ibm-anyuid-psp.yaml) / [`ibm-anyuid-cr`](ibm-anyuid-cr.yaml)

  This policy allows running pods as any user with any fsgroups / supplemental group ids and volumes (excludes hostPath).   Select default docker capabilities and privilege escalation are allowed.  No sysctls or host access are allowed.

- [`ibm-anyuid-hostpath-psp`](ibm-anyuid-hostpath-psp.yaml) / [`ibm-anyuid-hostpath-cr`](ibm-anyuid-hostpath-cr.yaml)

  This policy allows running pods as any user with any fsgroups / supplemental group ids and all volumes.   Select default docker capabilities, privilege escalation, and safe sysctls are allowed. No unsafe systctls or host access are allowed.
- [`ibm-anyuid-hostaccess-psp`](ibm-anyuid-hostaccess-psp.yaml) / [`ibm-anyuid-hostaccess-cr`](ibm-anyuid-hostaccess-cr.yaml)

  This policy adds full host access to `ibm-anyuid-hostpath`, allowing running pods as any user with any fsgroups / supplemental group ids and all volumes.  Select default docker capabilities, privilege escalation, host access (hostIPC, hostPID, hostNetwork, hostPorts), and safe sysctls are allowed. No unsafe systctls are allowed.

- [`ibm-privileged-psp`](ibm-privileged-psp.yaml) / [`ibm-privileged-cr`](ibm-privileged-cr.yaml)

  This policy is the least restrictive and provides all privileged access.

## Applying IBM Cloud Pak PodSecurityPolicy and ClusterRole resources to your cluster
IBM Cloud Private and IBM Cloud Kubernetes Service pre-install the IBM Cloud Pak PodSecurityPolicy and ClusterRole resources on your behalf.  However,if you wish to update them to a later version or on a non-IBM Kubernetes cluster, you can the follow steps in this section.

#### Pre-requisites:
-  The [Kubernetes command line interface (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl/) is installed and configured.
-  A user with cluster administrator permissions is logged-in to the `kubectl` CLI. 
   -  For IBM Cloud Private, use [`cloudctl login`](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/cli_commands.html#login)
   -  For IBM Cloud Kubernetes Service, use the [`ibmcloud`](https://cloud.ibm.com/docs/containers/cs_cli_install.html) CLI.

#### To apply the IBM Cloud Pak PodSecurityPolicy and ClusterRole resources to your cluster:
1.  Clone the IBM Cloud Pak git repository: `git clone https://github.com/IBM/cloud-pak`
2.  Apply all of the specification yaml files to your cluster:  `kubectl apply -f cloud-pak/spec/security/psp/.`

#### Result:  
PodSecurityPolicies and ClusterRoles are created or updated in your cluster.

## Applying a PodSecurityPolicy to your namespace
This procedure describes how to create a RoleBinding to bind all ServiceAccounts in a namespace to a pre-defined PodSecurityPolicy.  

#### Pre-requisites:
-  The PodSecurityPolicy and ClusterRole resources have been applied to the cluster.
-  The [Kubernetes command line interface (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl/) is installed and configured.
-  A user with cluster administrator permissions is logged-in to the `kubectl` CLI. 
   -  For IBM Cloud Private, use [`cloudctl login`](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/cli_commands.html#login)
   -  For IBM Cloud Kubernetes Service, use the [`ibmcloud`](https://cloud.ibm.com/docs/containers/cs_cli_install.html) CLI.

#### To bind all ServiceAccounts in a namespace to a PodSecurityPolicy:
Run the following command:

`kubectl -n <namespace-name> create rolebinding <rolebinding-name> --clusterrole=<psp-clusterrole-name> --group=system:serviceaccounts:<namespace-name>`

Where:

- `namespace-name` = The name of Kubernetes namespace to bind to the target PodSecurityPolicy.
- `rolebinding-name` = The name of the RoleBinding resource to create in the namespace.
- `psp-clusterrole-name` = The name of the ClusterRole associated with the target PodSecurityPolicy.

Example:

`kubectl -n appsales create rolebinding ibm-anyuid-clusterrole-rolebinding --clusterrole=ibm-anyuid-clusterrole --group=system:serviceaccounts:appsales`

## Validating which PodSecurityPolicies are bound to a namespace
Use the [`kubectl auth can-i`](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#checking-api-access) command to determine if a user or ServiceAccount has authority to use a PodSecurityPolicy.  

See the utility script [getPSP.sh](../../../samples/utilities/README.md) for an example on how to see all PodSecurityPolicies that are bound to a namespace.

## More information
For additional information about Kubernetes pod security policies, see:  https://kubernetes.io/docs/concepts/policy/pod-security-policy/
