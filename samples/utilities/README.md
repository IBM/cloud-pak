# IBM Cloud Pak Utilities
The following utilities are included as samples for working with an IBM Cloud Pak.

- [IBM Cloud Pak Utilities](#ibm-cloud-pak-utilities)
  - [getPSPs.sh](#getpspssh)
  - [getSCCs.sh (Red Hat OpenShift only)](#getsccssh-red-hat-openshift-only)
  - [checkPrereqs.sh](#checkprereqssh)

## getPSPs.sh
The getPSPs.sh bash script displays all of the PodSecurityPolicy resources that are 
mapped to each of the ServiceAccount users in the specified namespace.

Usage:
1.  Install the `kubectl` Kubernetes CLI.
2.  Login to your Kubernetes cluster and configure `kubectl` with a user that has sufficient privileges to access the namepace you wish to inspect.
3.  `./getPSPs.sh <namespace>`

Output:
The script will show every PSP that is assigned to one or more ServiceAccount in the namespace, and a comma-separated list of service account names within the namespace or `*` if one or more groups are bound to the PodSecurityPolicy.

In the following example, all users are bound to the `ibm-restricted-psp` in the `cert-manager` namespace and the `default` service account is also bound to `ibm-privileged-psp`. This means that any pod in the namespace can resolve to either SCC, depending on what service account is specified.
```
./getPSPs.sh cert-manager
Checking PSP configuration for namespace: cert-manager
ibm-privileged-psp (default)
ibm-restricted-psp (*, default)
```

## getSCCs.sh (Red Hat OpenShift only)
The getSCCs.sh bash script displays all of the SecurityContextConstraints resources that are 
mapped to each of the ServiceAccount users in the specified namespace (or project).

Usage:
1.  Install the `kubectl` Kubernetes CLI.
2.  Login to your Kubernetes cluster and configure `kubectl` with a user that has sufficient privileges to access the namepace you wish to inspect.
3.  `./getSCCs.sh <namespace>`

Output:
The script will show every SCC that is assigned to one or more ServiceAccount in the namespace, and a comma-separated list of service account names within the namespace.  This script also checks for any groups that may also resolve as follows:
`*sys:sa:ns` - The `system:serviceaccounts:<namespace>` group.  All service accounts in the namespace.
`*sys:auth` - The `system:authenticated` group.  All authenticated users.
`*sys:sa` - The `system:serviceaccounts` group.  All service accounts

In the following example, all users are bound to the `ibm-restricted-scc` resource and all service accounts in the `cert-manager` namespace are bound to the `icp-scc` resource.  This means that any pod in the namespace can resolve to either SCC.
```
./getSCCs.sh cert-manager
Checking SCC configuration for namespace: cert-manager
icp-scc (*sys:sa:ns)
ibm-restricted-scc (*sys:auth)
```

## checkPrereqs.sh
The checkPrereqs.sh script is a sample utility that can be used to determine if the target cluster has specific prerequistes installed.  Cloud Paks can use this script as part of a pre-installation verification step to verify that the target cluster satisfies the minimum requirements of the cloud pak.  

To use the utility:
1.  Install `kubectl`, `jq` and `curl` command line utilities.
2.  Login to the `kubectl` command-line as a cluster administrator (use `cloudctl` for IBM Cloud Private)
3.  To view the status of all known IBM Cloud Private management services:
    1.  `./checkPrereqs.sh check --allicpservices`
4.  To view the status of specific IBM Cloud Private management services:
    1.  `./checkPrereqs.sh check --icpservices cert-manager,image-manager`
5.  To view a list of all  IBM Cloud Private management services that this utility checks for:
    1.  `./checkPrereqs.sh list --allicpservices`

Example outputs with exit code:
```
$ ./checkPrereqs.sh check --icpservices auth-idp,image-manager
IBM Cloud Private management services:
auth-idp: INSTALLED
image-manager: INSTALLED
$ echo $?
0
```

```
$ ./checkPrereqs.sh check --icpservices auth-idp,istio
IBM Cloud Private management services:
auth-idp: INSTALLED
istio: NOT_INSTALLED
$ echo $?
1
```