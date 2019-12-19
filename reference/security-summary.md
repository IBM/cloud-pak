

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
| ibm-cloud-appmgmt-prod | ibm-privileged-psp |
| ibm-cloud-cost-asset-mgmt-prod | ibm-anyuid-psp |
| ibm-cloud-mgmt-platform-prod | ibm-anyuid-psp |
| ibm-csi-nfs | ibm-privileged-psp |
| ibm-datapower-dev | ibm-anyuid-psp |
| ibm-datapower-nonprod | ibm-anyuid-psp |
| ibm-datapower-prod | ibm-anyuid-psp |
| ibm-db2oltp-aese | ibm-privileged-psp |
| ibm-db2oltp-aese-rhos | ibm-privileged-psp |
| ibm-db2oltp-dae | ibm-privileged-psp |
| ibm-db2oltp-dev | ibm-privileged-psp |
| ibm-dba-content-prod | ibm-privileged-psp |
| ibm-dba-contentsearch | ibm-restricted-psp |
| ibm-dba-contentservices | ibm-restricted-psp |
| ibm-dba-cscmis | ibm-restricted-psp |
| ibm-dba-extshare-prod | ibm-restricted-psp |
| ibm-dba-multicloud-prod | ibm-privileged-psp |
| ibm-dba-navigator | ibm-restricted-psp |
| ibm-dsm-dev | ibm-privileged-psp |
| ibm-dsm-prod-x86-64 | ibm-privileged-psp |
| ibm-dsx-dev | ibm-privileged-psp |
| ibm-dsx-prod | ibm-privileged-psp |
| ibm-dsx-prod-ppc64le | ibm-privileged-psp |
| ibm-eventstreams-dev | ibm-restricted-psp |
| ibm-eventstreams-foundation-prod | ibm-restricted-psp |
| ibm-eventstreams-prod | ibm-restricted-psp |
| ibm-eventstreams-rhel-prod |  |
| ibm-f5bigip-controller | ibm-anyuid-psp |
| ibm-galera-mariadb-dev | ibm-anyuid-hostpath-psp |
| ibm-glusterfs | ibm-privileged-psp |
| ibm-hazelcast-dev | ibm-anyuid-psp |
| ibm-ilmt | ibm-privileged-psp |
| ibm-istio | ibm-privileged-psp |
| ibm-istio-remote | ibm-privileged-psp |
| ibm-kerify-dev | ibm-anyuid-psp |
| ibm-lsfce-dev | ibm-privileged-psp |
| ibm-mariadb-dev | ibm-anyuid-psp |
| ibm-maximo-po-prod | ibm-restricted-psp |
| ibm-messagesight-dev | ibm-privileged-psp |
| ibm-messagesight-prod | ibm-privileged-psp |
| ibm-mfpf-analytics-prod | ibm-anyuid-psp |
| ibm-mfpf-appcenter-prod | ibm-anyuid-psp |
| ibm-mfpf-server-prod | ibm-anyuid-psp |
| ibm-microclimate | ibm-anyuid-hostpath-psp |
| ibm-minio-objectstore | ibm-anyuid-psp |
| ibm-mobilefoundation-dev | ibm-restricted-psp |
| ibm-mobilefoundation-prod |  |
Copyright 2018, IBM Corporation 
