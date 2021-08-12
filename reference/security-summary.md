

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
| ibm-ace-server-dev | ibm-anyuid-psp |
| ibm-ace-server-prod | ibm-anyuid-psp |
| ibm-aiopenscale-prod |  |
Copyright 2018, IBM Corporation 
