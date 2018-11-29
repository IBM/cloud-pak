

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
| ibm-ace-dev | ibm-anyuid-psp |
| ibm-ace-prod | ibm-anyuid-psp |
| ibm-ace-server-dev | ibm-anyuid-psp |
| ibm-ace-server-prod | ibm-anyuid-psp |
| ibm-apiconnect-ent | ibm-privileged-psp |
| ibm-apiconnect-pro | ibm-privileged-psp |
| ibm-aspera-cli | ibm-anyuid-psp |
| ibm-blockchain-platform-remote-peer | ibm-anyuid-hostpath-psp |
| ibm-calico-bgp-peer | ibm-privileged-psp |
| ibm-cam | ibm-anyuid-hostpath-psp |
| ibm-cem | ibm-anyuid-psp |
| ibm-cloud-appmgmt-prod | ibm-privileged-psp |
| ibm-cloud-mgmt-platform-prod | ibm-privileged-psp |
| ibm-csi-nfs | ibm-privileged-psp |
| ibm-datapower-dev | ibm-anyuid-psp |
| ibm-datapower-nonprod | ibm-anyuid-psp |
| ibm-datapower-prod | ibm-anyuid-psp |
| ibm-db2oltp-aese | ibm-privileged-psp |
| ibm-db2oltp-aese-rhos | ibm-privileged-psp |
| ibm-db2oltp-dae | ibm-privileged-psp |
| ibm-db2oltp-dev | ibm-privileged-psp |
| ibm-dba-content-prod | ibm-privileged-psp |
| ibm-dba-multicloud-prod | ibm-privileged-psp |
| ibm-dsm-dev | ibm-privileged-psp |
| ibm-dsm-prod-x86-64 | ibm-privileged-psp |
| ibm-dsx-dev | ibm-privileged-psp |
| ibm-dsx-prod | ibm-privileged-psp |
| ibm-dsx-prod-ppc64le | ibm-privileged-psp |
| ibm-eventstreams-dev | ibm-restricted-psp |
| ibm-eventstreams-foundation-prod | ibm-restricted-psp |
| ibm-eventstreams-prod | ibm-restricted-psp |
| ibm-f5bigip-controller | ibm-anyuid-psp |
| ibm-galera-mariadb-dev | ibm-anyuid-hostpath-psp |
| ibm-glusterfs | ibm-privileged-psp |
| ibm-hazelcast-dev | ibm-anyuid-psp |
| ibm-icplogging | ibm-privileged-psp |
| ibm-icplogging-kibana | ibm-privileged-psp |
| ibm-icpmonitoring | ibm-anyuid-hostaccess-psp |
| ibm-integration-bus-dev | ibm-anyuid-psp |
| ibm-integration-bus-prod | ibm-anyuid-psp |
| ibm-istio | ibm-privileged-psp |
| ibm-istio-remote | ibm-privileged-psp |
| ibm-jenkins-dev | ibm-privileged-psp |
| ibm-lsfce-dev | ibm-privileged-psp |
| ibm-mariadb-dev | ibm-anyuid-psp |
| ibm-messagesight-dev | ibm-anyuid-hostaccess-psp |
| ibm-mfpf-analytics-prod | ibm-anyuid-psp |
| ibm-mfpf-appcenter-prod | ibm-anyuid-psp |
| ibm-mfpf-server-prod | ibm-anyuid-psp |
| ibm-microclimate | ibm-anyuid-hostpath-psp |
| ibm-minio-objectstore | ibm-anyuid-psp |
| ibm-mongodb-dev | ibm-anyuid-psp |
| ibm-mqadvanced-server-dev | ibm-anyuid-psp |
| ibm-mqadvanced-server-prod | ibm-anyuid-psp |
| ibm-mqadvanced-server-rhel-prod | ibm-anyuid-psp |
| ibm-netcool-asm-prod | ibm-anyuid-psp |
| ibm-netcool-piagent-prometheus-dev | ibm-anyuid-psp |
| ibm-netcool-piagent-prometheus-prod | ibm-anyuid-psp |
| ibm-netcool-probe-dev | ibm-privileged-psp |
| ibm-netcool-probe | ibm-privileged-psp |
| ibm-netcool-probe-messagebus-kafka-prod  | ibm-privileged-psp |
| ibm-netcool-probe-messagebus-webhook-prod | ibm-privileged-psp |
| ibm-netcool-probe-snmp-prod | ibm-anyuid-psp |
| ibm-netcool-probe-syslogd-prod | ibm-anyuid-psp |
| ibm-netcool-probe-tivolieif-prod | ibm-anyuid-psp |
| ibm-netcool-prod | ibm-privileged-psp |
| ibm-nginx-dev | ibm-anyuid-psp |
| ibm-nodejs-sample | ibm-anyuid-psp |
| ibm-odm-dev | ibm-anyuid-psp |
| ibm-odm-prod | ibm-anyuid-psp |
| ibm-open-liberty | ibm-anyuid-psp |
| ibm-postgres-dev | ibm-anyuid-psp |
| ibm-powerai-enterprise-prod | ibm-privileged-psp |
| ibm-powerai | ibm-anyuid-hostaccess-psp |
| ibm-powerai-vision-prod | ibm-anyuid-hostpath-psp |
| ibm-powervc-k8s-volume-driver | ibm-anyuid-hostpath-psp |
| ibm-rabbitmq-dev | ibm-anyuid-psp |
| ibm-reactive-platform-lagom-sample | ibm-anyuid-psp |
| ibm-redis-ha-dev | ibm-anyuid-psp |
| ibm-rook-rbd-cluster | ibm-privileged-psp |
| ibm-skydive-dev | ibm-privileged-psp |
| ibm-spectrum-conductor | ibm-privileged-psp |
| ibm-spectrum-symphony-dev | ibm-privileged-psp |
| ibm-spectrum-symphony-prod | ibm-privileged-psp |
| ibm-strongswan | ibm-privileged-psp |
| ibm-swift-sample | ibm-anyuid-psp |
| ibm-transadv-dev | ibm-anyuid-psp |
| ibm-ucd-prod | ibm-anyuid-psp |
| ibm-voice-gateway-dev | ibm-anyuid-hostaccess-psp |
| ibm-voice-gateway-prod | ibm-anyuid-hostaccess-psp |
| ibm-was-vm-quickstarter-dev | ibm-anyuid-psp |
| ibm-was-vm-quickstarter-prod | ibm-anyuid-psp |
| ibm-watson-compare-comply-prod | ibm-anyuid-psp |
| ibm-watson-speech-prod | ibm-privileged-psp |
| ibm-websphere-liberty | ibm-anyuid-psp |
| ibm-websphere-liberty-rhel | ibm-anyuid-psp |
| ibm-websphere-traditional | ibm-restricted-psp |
| ibm-webterminal-dev | ibm-privileged-psp |
| ibm-wex-prod | ibm-anyuid-psp |
| ibm-ws-dyn-agent-dev | ibm-anyuid-psp |
| ibm-ws-dyn-agent-prod | ibm-anyuid-psp |
Copyright 2018, IBM Corporation 
