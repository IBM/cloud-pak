

# Chart Security Summary
This page describes a summary of some of the security requirements of
Helm charts available on IBM Cloud.  If a chart is not listed here, consult
the chart's documentation for instructions.

#### Table columns:
**Chart:**  The name of the chart.

**Pod security policy:**  The pre-defined pod security policy.  See the  [IBM Cloud Pak pod security policy definitions](../spec/security/psp) for details.

## Chart security reference

| Chart | Pod security policy |
|:----------|:---------------|
| ibm-ace-dashboard-dev | ibm-anyuid-psp |
| ibm-ace-dashboard-prod | ibm-anyuid-psp |
| ibm-ace-dashboard-rhel-prod | ibm-anyuid-psp |
| ibm-ace-server-dev | ibm-anyuid-psp |
| ibm-ace-server-prod | ibm-anyuid-psp |
| ibm-ace-server-rhel-prod | ibm-anyuid-psp |
| ibm-aiopenscale-prod | ibm-restricted-psp |
| ibm-alm-prod | ibm-anyuid-psp |
| ibm-apiconnect-ent | ibm-privileged-psp |
| ibm-apiconnect-pro | ibm-privileged-psp |
| ibm-app-navigator | ibm-restricted-psp |
| ibm-aspera-cli | ibm-anyuid-psp |
| ibm-aspera-hsts-prod | ibm-anyuid-hostaccess-psp |
| ibm-blockchain-platform-dev | ibm-privileged-psp |
| ibm-blockchain-platform-prod | ibm-privileged-psp |
| ibm-calico-bgp-peer | ibm-privileged-psp |
| ibm-cam | ibm-anyuid-hostpath-psp |
| ibm-cem | ibm-anyuid-psp |
| ibm-cip-prod |  |
Copyright 2018, IBM Corporation 
