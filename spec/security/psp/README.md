# IBM Cloud Pak Pod Security Policy Definitions
The IBM Cloud Pak specification defines several pre-defined Kubernetes Pod Security Policy definitions.  These policies are pre-loaded on IBM Cloud platforms and are referenced by IBM Cloud Paks to describe their pod security requirements.

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

## More information
For additional information about Kubernetes pod security policies, see:  https://kubernetes.io/docs/concepts/policy/pod-security-policy/
