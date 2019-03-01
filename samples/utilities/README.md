# IBM Cloud Pak Utilities
The following utilities are included as samples for working with an IBM Cloud Pak.

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
