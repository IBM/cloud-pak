# IBM Cloud Pak PodSecurityPolicy Definitions
The IBM Cloud Pak specification defines several pre-defined Kubernetes PodSecurityPolicy definitions.  These policies are pre-loaded on IBM Cloud platforms and are referenced by IBM Cloud Paks to describe their pod security requirements.

When the PodSecurityPolicy definitions are not pre-loaded, use the instructions in this document to install and update them into your Kubernetes cluster.

- [PodSecurityPolicy Reference](#podsecuritypolicy-reference)
- [Applying IBM Cloud Pak PodSecurityPolicy resources to your cluster](#applying-ibm-cloud-pak-podsecuritypolicy-resources-to-your-cluster)
- [Applying a PodSecurityPolicy to your namespace](#applying-a-podsecuritypolicy-to-your-namespace)
- [Validating which PodSecurityPolicies are bound to a namespace](#validating-which-podsecuritypolicies-are-bound-to-a-namespace)
- [More information](#more-information)
- [Change Logs](#change-logs)

## PodSecurityPolicy Reference
The following PodSecurityPolicies are available on IBM Cloud.  Each PodSecurityPolicy file includes an associated ClusterRole:

- [`ibm-restricted-psp`](ibm-restricted-psp.yaml)

  This policy is the most restrictive, forcing pods to declare their requirements, avoiding platform or cluster-specific configuration differences.
- [`ibm-anyuid-psp`](ibm-anyuid-psp.yaml)

  This policy allows running pods as any user with any fsgroups / supplemental group ids and volumes (excludes hostPath).   Select default docker capabilities and privilege escalation are allowed.  No sysctls or host access are allowed.

- [`ibm-anyuid-hostpath-psp`](ibm-anyuid-hostpath-psp.yaml)

  This policy allows running pods as any user with any fsgroups / supplemental group ids and all volumes.   Select default docker capabilities, privilege escalation, and safe sysctls are allowed. No unsafe systctls or host access are allowed.
- [`ibm-anyuid-hostaccess-psp`](ibm-anyuid-hostaccess-psp.yaml)

  This policy adds full host access to `ibm-anyuid-hostpath`, allowing running pods as any user with any fsgroups / supplemental group ids and all volumes.  Select default docker capabilities, privilege escalation, host access (hostIPC, hostPID, hostNetwork, hostPorts), and safe sysctls are allowed. No unsafe systctls are allowed.

- [`ibm-privileged-psp`](ibm-privileged-psp.yaml)

  This policy is the least restrictive and provides all privileged access.

## Applying IBM Cloud Pak PodSecurityPolicy resources to your cluster
IBM Cloud Private and IBM Cloud Kubernetes Service pre-install the IBM Cloud Pak PodSecurityContext and ClusterRole resources on your behalf.  However, if you wish to update them to a later version or on a non-IBM Kubernetes cluster, you can the steps in this section.

#### Pre-requisites:
-  The PodSecurityPolicy and ClusterRole resources have been applied to the cluster.
-  The [Kubernetes command line interface (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl/) is installed and configured.
-  A user with cluster administrator permissions is logged-in to the `kubectl` CLI.
   -  For IBM Cloud Private, use [`cloudctl login`](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/cli_commands.html#login)
   -  For IBM Cloud Kubernetes Service, use the [`ibmcloud`](https://cloud.ibm.com/docs/containers/cs_cli_install.html) CLI.

#### To apply the IBM Cloud Pak PodSecurityPolicy resources to your cluster:
1.  Clone the IBM Cloud Pak git repository: `git clone https://github.com/IBM/cloud-pak`
2.  Apply the specification yaml files to your cluster:  `kubectl apply -f cloud-pak/spec/security/psp`

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

`namespace-name` = The name of Kubernetes namespace to bind to the target PodSecurityPolicy.
`rolebinding-name` = The name of the RoleBinding resource to create in the namespace.
`psp-clusterrole-name` = The name of the ClusterRole associated with the target PodSecurityPolicy.

Example:

`kubectl -n appsales create rolebinding ibm-anyuid-clusterrole-rolebinding --clusterrole=ibm-anyuid-clusterrole --group=system:serviceaccounts:appsales`

## Validating which PodSecurityPolicies are bound to a namespace
Use the [`kubectl auth can-i`](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#checking-api-access) command to determine if a user or ServiceAccount has authority to use a PodSecurityPolicy.

See the utility script [getPSP.sh](../../../samples/utilities/README.md) for an example on how to see all PodSecurityPolicies that are bound to a namespace.

## Change Logs
List of changed made for the PSPs based on version
### Version 1.1.0
- The apiGroup changed from extentions/v1beta1 --> policy/v1beta1
- The custom resource definitions file changed the apiGroups from extentions -> v1beta1
- Added in the runAsGoup field to the PSPs, as is supported since version 1.14 of Kube.


## More information
For additional information about Kubernetes PodSecurityPolicy, see:  https://kubernetes.io/docs/concepts/policy/pod-security-policy/

For additional information about using PodSecurityPolicy with IBM Cloud Private, see the [Pod Isolation topic in the IBM Cloud Private Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/user_management/iso_pod.html)
