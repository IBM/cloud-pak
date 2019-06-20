#/bin/sh

# This script is helper utility that can determine what dependencies are 
# are installed in the cluster.
#
# Current dependency resolvers include:
# - IBM Cloud Private Management Services
# 
# To use this script, you must first setup your kubectl CLI and login to the target cluster with a user
# who has the cluster administrator role.
#
# Pre-requisites:
#  kubectl    https://kubernetes.io/docs/tasks/tools/install-kubectl/
#  jq         https://stedolan.github.io/jq/
#  curl 
#  bash 
#
# Dump all the service names known by this tool.
#  checkPrereqs.sh list
# Dump all the installed services for the connected cluster
#  checkPrereqs.sh check --allicpservices
# Test for selected services to see if they are installed.
#  checkPrereqs.sh check --icpservices audit-logging,cert-manager
# 
# A non-zero exit code indicates that at least one of the specified services is NOT installed.

echoerr() { 
  echo "$@" 1>&2; 
}


show_help() {
  echo "checkPrereqs.sh checks the availability of various dependencies using the current kubectl security context "
  echo ""
  echo "Usage:  checkPrereqs.sh [command] [command flags]"
  echo ""
  echo "Commands:"
  echo "   check            Checks the cluster for availability of one or more services."
  echo "   list             Displays the services known by this utility without connecting to the cluster."
  echo ""
  echo "check Options:"
  echo "   --allicpservices    Lists all IBM Cloud Private services and their status."
  echo "   --icpservices  <comma-delimited IBM Cloud Private service names>"
  echo "                    Lists the status of the specified services."
  echo "list Options:"
  echo "   --allicpservices    Lists all IBM Cloud Private services and their status."
  echo ""
  echo "Command Flags:"
  echo "   -v               Verbose"
}

ACTION=
SERVICES=
ARGS=$@
VERBOSE=0

COMMAND=$1
if [ "$COMMAND" == "check" ]; then
  shift
  while [ "$1" != "" ]; do
      case $1 in
          --allicpservices ) shift
                          if [ ! -z $ACTION ]; then echo "Only one flag allowed.  "; show_help; exit 1; fi
                          ACTION="ALL"
                          ;;
          --icpservices )    shift
                          if [ ! -z $ACTION ]; then echo "Only one flag allowed.  "; show_help; exit 1; fi
                          ACTION="SELECT"
                          SERVICES="${1}"
                          ;;
          -v )            
                          VERBOSE=1
                          echo VERBOSE=$VERBOSE
                          ;;
          *) 
                          echoerr "Invalid flag: ${1}"
                          show_help
                          exit 1
                          ;;
      esac
      shift
  done
elif [ "$COMMAND" == "list" ]; then
  shift
  while [ "$1" != "" ]; do
      case $1 in
          --allicpservices ) shift
                          if [ ! -z $ACTION ]; then echo "Only one flag allowed.  "; show_help; exit 1; fi
                          ACTION="ALL"
                          ;;
          -v )            
                          VERBOSE=1
                          echo VERBOSE=$VERBOSE
                          ;;
          *) 
                          echoerr "Invalid flag: ${1}"
                          show_help
                          exit 1
                          ;;
      esac
      shift
  done
else
  show_help
  exit 1
fi


TMPPFX=$(basename -- "$0")
MAPDIR_STRATEGY=$(mktemp -dt ${TMPPFX})
MAPDIR_DIRECT=$(mktemp -dt ${TMPPFX})
MAPDIR_CRD=$(mktemp -dt ${TMPPFX})
trap 'rm -r ${MAPDIR_STRATEGY} && rm -r ${MAPDIR_DIRECT} && rm -r ${MAPDIR_CRD}' EXIT

# Check for command prereqs
check_prereqs() {
  rc=0
  if ! type curl >/dev/null 2>&1; then
    echoerr 'Error: curl is not installed.' 
    rc=1
  fi

  if ! type kubectl >/dev/null 2>&1; then
    echoerr 'Error: kubectl is not installed.'
    rc=1
  fi

  if ! type jq >/dev/null 2>&1; then
    echoerr 'Error: jq is not installed.'
    rc=1
  fi
  if [ $rc -ne 0 ]; then 
    echo Aborting...
    exit 1; 
  fi
}

# The ICP Management Endpoint
ICP_MGMT_ENDPOINT=
# The ICP System Healthcheck Service endpoint
ICP_CLUSTER_HEALTH_URL=
setup_endpoints() {
  ICP_MGMT_ENDPOINT="$(get_icp_endpoint)"
  ICP_CLUSTER_HEALTH_URL="$ICP_MGMT_ENDPOINT/cluster-health/v1alpha1/clusterstatus"
}

# The cluster-health service uses the Kube token.
AUTHZTOKEN=
setup_authz_token() {
  # "$(cloudctl tokens --id)"
  current_context=$(kubectl config current-context)
  if [ $VERBOSE -gt 0 ]; then echoerr "get_authz_token: current_context=$current_context"; fi
  current_context_user=$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"${current_context}\")].context.user}")
  if [ $VERBOSE -gt 0 ]; then echoerr "get_authz_token: current_context_user=$current_context_user"; fi
  AUTHZTOKEN=$(kubectl config view -o jsonpath="{.users[?(@.name == \"${current_context_user}\")].user.token}")
}

# Test to see if the current user is authorized to run this script.
# stdout: None
# Return code: 0 if authorized
check_authz() {
  authz_response=$(kubectl auth can-i '*' '*' -n kube-system)
  if [ ! "$authz_response" = "yes" ]; then
    echo "Current user is not authorized to run this command.  The user must be a cluster administrator."
    echo Aborting...
    exit 10
  fi
}

strindex() { 
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

# stdout:  The IBM Cloud Private endpoint URL
get_icp_endpoint() {
  # $ cloudctl api 
  # API Endpoint:          https://9.46.67.224:8443   
  # API Version:           v1   
  # Skip SSL Validation:   true   
  APIINFO=$(cloudctl api)

  printf '%s\n' "$APIINFO" | while IFS= read -r line
  do
    if [[ $line == "API Endpoint:"* ]]; then
      idx=$(strindex "$line" "https://")
      echo ${line:$idx}
    fi
  done
}

# File-based dictionary structure
# put_direct_lookup_entry <key> <value>
put_lookup_strategy_entry() {
  [ "$#" != 2 ] && echo Aborting... && exit 1
  key=$1; value=$2
  [ -d "${MAPDIR_STRATEGY}" ] || mkdir "${MAPDIR_STRATEGY}"
  echo $value >"${MAPDIR_STRATEGY}/${key}"
}

# get_direct_lookup_entry <key>
# stdout: The value
get_lookup_strategy_entry() {
  [ "$#" != 1 ] && echo Aborting... && exit 1
  key=$1
  cat "${MAPDIR_STRATEGY}/${key}" 2>/dev/null
}

# File-based dictionary structure
# put_direct_lookup_entry <key> <value>
put_direct_lookup_entry() {
  [ "$#" != 2 ] && echo Aborting... && exit 1
  key=$1; value=$2
  [ -d "${MAPDIR_DIRECT}" ] || mkdir "${MAPDIR_DIRECT}"
  echo $value >"${MAPDIR_DIRECT}/${key}"
}

# get_direct_lookup_entry <key>
# stdout: The value
get_direct_lookup_entry() {
  [ "$#" != 1 ] && echo Aborting... && exit 1
  key=$1
  cat "${MAPDIR_DIRECT}/${key}" 2>/dev/null
}

# put_crd_lookup_entry <key> <value>
put_crd_lookup_entry() {
  [ "$#" != 2 ] && echo Aborting... && exit 1
  key=$1; value=$2
  [ -d "${MAPDIR_CRD}" ] || mkdir "${MAPDIR_CRD}"
  echo $value >"${MAPDIR_CRD}/${key}"
}

# get_crd_lookup_entry <key>
# stdout: The value
get_crd_lookup_entry() {
  [ "$#" != 1 ] && echo Aborting... && exit 1
  key=$1
  cat "${MAPDIR_CRD}/${key}" 2>/dev/null
}


# Test to see if any resources exist in the 'all' category using the specified label.
# stdout: None
# Return code:  0 if exists
resource_exists_by_label() {
  [ "$#" != 2 ] && echoerr "resource_exists_by_label() missing args: resource" && exit 1;
  LABEL=$1
  NAMESPACE=$2

  # Fail if no output.
  if [[ $(kubectl -n $NAMESPACE get all -l $LABEL -o name) ]]; then return 0; else return 1; fi
}

# Test to see if any resources exist using the canonical name.
# stdout: None
# Return code:  0 if exists
resource_exists_by_name() {
  [ "$#" != 2 ] && echoerr "resource_exists_by_name() missing args: resource" && exit 1;
  name=$1
  namespace=$2

  # Fail if no stdout
  if [[ $(kubectl -n $namespace get $name -o name 2>/dev/null) ]]; then return 0; else return 1; fi
}

# Test if a service is installed.
# stdout: None
# Return 0 if installed
# Return 1 if not installed
check_service_installed_direct() {
  if [ $VERBOSE -gt 0 ]; then echoerr "check_service_installed_direct: $1"; fi
  service_name=$1
  # <lookup strategy>|<parameters>
  value=$(get_direct_lookup_entry $service_name)

  if [ -z $value ]; then
    if [ $VERBOSE -gt 0 ]; then echoerr "Unknown service name: $service_name"; fi
    return 1
  fi
  
  set -f; IFS='|'
  set -- $value
  STRATEGY=$1; PARAMETERS=$2
  set +f; unset IFS

  if [ "$STRATEGY" = "label" ]; then
    # Parameters:  <Label>;<Namespace>
    set -f; IFS=';'
    set -- $PARAMETERS
    LABEL=$1; NAMESPACE=$2
    set +f; unset IFS
    resource_exists_by_label $LABEL $NAMESPACE
  elif [ "$STRATEGY" = "name" ]; then
    # Parameters:  <Name>;<Namespace>
    set -f; 
    IFS=';'
    set -- $PARAMETERS
    NAME=$1; NAMESPACE=$2
    set +f; unset IFS
    resource_exists_by_name $NAME $NAMESPACE
  else 
    echoerr "Invalid test strategy: $STRATEGY"
    echo Aborting...
    exit -1
  fi
  rc=$?
  return $rc
}

# Test if a service is installed.
# Return 0 if installed
# Return 1 if not installed
check_service_installed_crd() {
  if [ $VERBOSE -gt 0 ]; then echoerr "check_service_installed_crd: $1"; fi
  service_name=$1

  # <Comma-Separated CRD Names>
  crds=$(get_crd_lookup_entry $service_name)
  if [ $VERBOSE -gt 0 ]; then echoerr "checking crds: $crds"; fi
  
  for crd in ${crds//,/ }
  do
    resource_exists_by_name "customresourcedefinitions.apiextensions.k8s.io/$crd" "default"
    if [ $? -ne 0 ]; then
      if [ $VERBOSE -gt 0 ]; then echoerr "Missing CRD: $crd"; fi
      return 1
    fi
  done
  return 0
}

# Test if a service is installed.
# Return 0 if installed
# Return 1 if not installed
check_service_installed_syshealthchk() {
  if [ $VERBOSE -gt 0 ]; then echoerr "check_service_installed_syshealthchk: $1"; fi
  service_name=$1
  status_json=$2

  # Check if the service is found.
  echo $status_json | jq -er ".serviceStatus.\"$service_name\"" > /dev/null 2>&1 
  if [ $? -ne 0 ]; then
    if [ $VERBOSE -gt 0 ]; then echoerr "Service not known: $service_name"; fi
    return 3
  fi

  # If it is found, see if the status is present and not NotInstalled
  service_status=$(echo "$status_json" | jq -er ".serviceStatus.\"$service_name\".status")
  if [ $? -ne 0 ]; then
    if [ $VERBOSE -gt 0 ]; then echoerr "Service status not known: $service_name"; fi
    return 2
  fi

  if [ "$service_status" = "NotInstalled" ]; then
    if [ $VERBOSE -gt 0 ]; then echoerr "Service not installed: $service_name"; fi
    return 1
  fi
}


# Retrieve the ICP status JSON document (JSON response is in stdout)
# stdout: JSON response from the ICP System Health Service
# return code: 0 if installed
get_service_health_statuses() {
  cmd="curl -k -s -f -H \"Authorization: Bearer $AUTHZTOKEN\" -H 'Accept: application/json' $ICP_CLUSTER_HEALTH_URL"
  if [ $VERBOSE -gt 0 ]; then echoerr "Invoking command: $cmd"; fi
  eval "$cmd"
  rc=$?
  return $rc
}

# Checks if a service is installed.
# stdout: None
# return code: 0 if installed
check_service_installed() {
  service_name=$1
  status_json=$2
  rc=

  if [ $VERBOSE -gt 0 ]; then echoerr "check_service_installed $1 $2"; fi

  # Retrieve the lookup strategies.
  strategies=$(get_lookup_strategy_entry $service_name)

  if [ $VERBOSE -gt 0 ]; then echoerr "strategies: $strategies"; fi

  # Return on the first success.
  for strategy in ${strategies//,/ }
  do
    case $strategy in
            crd )           if check_service_installed_crd "$service_name"; then return 0; fi
                            ;;
            syshealthsvc )  if [ ! -z "$status_json" ] && check_service_installed_syshealthchk "$service_name" "$status_json" ; then return 0; fi
                            ;;
            direct )        if check_service_installed_direct "$service_name" ; then return 0; fi
                            ;;
            *) 
                            echoerr "Invalid strategy: ${strategy}"
                            exit 1
                            ;;
      esac
  done

  # Not installed.
  return 1;
}


# Check the status of multiple services.
# stdout:  <service_name>: INSTALLED|NOT_INSTALLED
check_select_services() {
  if [ $VERBOSE -gt 0 ]; then echoerr "check_select_services $1"; fi
  failed=0
  service_names=$1

  status_json="$(get_service_health_statuses)"
  status_json_rc=$?
  if [ ! $status_json_rc -eq 0 ]; then 
    echoerr "ICP System Health Service not available (rc=$status_json_rc)."
  fi

  for service_name in ${service_names//,/ }
  do
    check_service_installed "$service_name" "$status_json"
    rc=$?
    if (( rc == 0 )); then echo  "$service_name: INSTALLED"; else echo "$service_name: NOT_INSTALLED"; fi
    if (( rc != 0 && failed == 0 ));then failed=$rc; fi
  done
  return $failed;
}

# Get all known service names
# stodut  All known services, one per line
get_service_names() {
  if [ $VERBOSE -gt 0 ]; then echoerr "get_service_name"; fi
  wd=`pwd`
  cd $MAPDIR_STRATEGY
  for n in *; do 
    printf '%s\n' "$n"
  done
  cd $wd
}

# Get all known service names as comma-sep list
# stodut  All known services in a comma-delimeted list.
get_service_list() {
  if [ $VERBOSE -gt 0 ]; then echoerr "get_service_list"; fi
  wd=`pwd`
  cd $MAPDIR_STRATEGY
  services=
  for n in *; do 
    services="$services,$(printf '%s' "$n")"
  done
  echo "$services"
  cd $wd
}


# Build up a table of all known services and the strategy for determining their availability
setup_lookup_strategies() {
  # There must be one Lookup Strategy for each service

  # Map of Service Name, <Comma Separated list of Stragegies>
  #  Strategies:  syshealthsvc,crd,direct
  put_lookup_strategy_entry "audit-logging" "syshealthsvc,direct"
  put_lookup_strategy_entry "auth-apikeys" "syshealthsvc,direct"
  put_lookup_strategy_entry "auth-idp" "syshealthsvc,direct"
  put_lookup_strategy_entry "auth-pap" "syshealthsvc,direct"
  put_lookup_strategy_entry "auth-pdp" "syshealthsvc,direct"
  put_lookup_strategy_entry "catalog-ui" "syshealthsvc,direct"
  put_lookup_strategy_entry "cert-manager" "syshealthsvc,crd,direct"
  put_lookup_strategy_entry "custom-metrics-adapter" "syshealthsvc,direct"
  put_lookup_strategy_entry "heapster" "syshealthsvc,direct"
  put_lookup_strategy_entry "helm-api" "syshealthsvc,direct"
  put_lookup_strategy_entry "helm-repo" "syshealthsvc,direct"
  put_lookup_strategy_entry "icp-management-ingress" "syshealthsvc,direct"
  put_lookup_strategy_entry "image-manager" "syshealthsvc,direct"
  put_lookup_strategy_entry "image-security-enforcement" "syshealthsvc,direct"
  put_lookup_strategy_entry "istio" "syshealthsvc,direct"
  put_lookup_strategy_entry "key-management-api" "syshealthsvc,direct"
  put_lookup_strategy_entry "logging" "syshealthsvc,direct"
  put_lookup_strategy_entry "mariadb" "syshealthsvc,direct"
  put_lookup_strategy_entry "metering-dm" "syshealthsvc,direct"
  put_lookup_strategy_entry "metrics-server" "syshealthsvc,direct"
  put_lookup_strategy_entry "mgmt-repo" "syshealthsvc,direct"
  put_lookup_strategy_entry "mongodb" "syshealthsvc,direct"
  put_lookup_strategy_entry "monitoring" "syshealthsvc,direct"
  put_lookup_strategy_entry "multicluster-endpoint" "syshealthsvc,direct"
  put_lookup_strategy_entry "multicluster-hub" "syshealthsvc,direct"
  put_lookup_strategy_entry "nginx-ingress" "syshealthsvc,direct"
  put_lookup_strategy_entry "node-problem-detector-draino" "syshealthsvc,direct"
  put_lookup_strategy_entry "nvidia-device-plugin" "syshealthsvc,direct"
  put_lookup_strategy_entry "platform-api" "syshealthsvc,direct"
  put_lookup_strategy_entry "platform-security-netpols" "syshealthsvc,direct"
  put_lookup_strategy_entry "platform-ui" "syshealthsvc,direct"
  put_lookup_strategy_entry "secret-watcher" "syshealthsvc,direct"
  put_lookup_strategy_entry "security-onboarding" "syshealthsvc,direct"
  put_lookup_strategy_entry "service-catalog" "syshealthsvc,direct"
  put_lookup_strategy_entry "storage-glusterfs" "syshealthsvc,direct"
  put_lookup_strategy_entry "system-healthcheck-service" "syshealthsvc,direct"
  put_lookup_strategy_entry "tiller" "syshealthsvc,direct"
  put_lookup_strategy_entry "unified-router" "syshealthsvc,direct"
  put_lookup_strategy_entry "vulnerability-advisor" "syshealthsvc,direct"
  put_lookup_strategy_entry "web-terminal" "syshealthsvc,direct"

  # CustomResourceDefinition Lookups
  # Map of Service Name, <Comma Separated CRD Names>
  put_crd_lookup_entry "cert-manager" "certificates.certmanager.k8s.io,clusterissuers.certmanager.k8s.io,issuers.certmanager.k8s.io"

  # Direct Resource lookups
  # Map of Service Name, <Lookup Method>|<Lookup Arguments>
  put_direct_lookup_entry "audit-logging" "label|release=audit-logging;kube-system"
  put_direct_lookup_entry "auth-apikeys" "label|release=auth-apikeys;kube-system"
  put_direct_lookup_entry "auth-idp" "label|release=auth-idp;kube-system"
  put_direct_lookup_entry "auth-pap" "label|release=auth-pap;kube-system"
  put_direct_lookup_entry "auth-pdp" "label|release=auth-pdp;kube-system"
  put_direct_lookup_entry "catalog-ui" "label|k8s-app=catalog-ui;kube-system"
  put_direct_lookup_entry "cert-manager" "label|release=cert-manager;cert-manager"
  put_direct_lookup_entry "custom-metrics-adapter" "label|release=custom-metrics-adapter;kube-system"
  put_direct_lookup_entry "heapster" "label|k8s-app=heapster;kube-system"
  put_direct_lookup_entry "helm-api" "label|app=helm-api;kube-system"
  put_direct_lookup_entry "helm-repo" "label|app=helm-repo;kube-system"
  put_direct_lookup_entry "icp-management-ingress" "label|release=icp-management-ingress;kube-system"
  put_direct_lookup_entry "image-manager" "label|app=image-manager;kube-system"
  put_direct_lookup_entry "image-security-enforcement" "label|release=image-security-enforcement;kube-system"
  put_direct_lookup_entry "istio" "label|release=istio;istio-system"
  put_direct_lookup_entry "key-management-api" "label|app=key-management-api;kube-system"
  put_direct_lookup_entry "logging" "label|release=logging;kube-system"
  put_direct_lookup_entry "mariadb" "label|release=mariadb;kube-system"
  put_direct_lookup_entry "metering-dm" "label|app=metering-dm;kube-system"
  put_direct_lookup_entry "metrics-server" "label|k8s-app=metrics-server;kube-system"
  put_direct_lookup_entry "mgmt-repo" "label|app=mgmt-repo;kube-system"
  put_direct_lookup_entry "mongodb" "label|release=mongodb;kube-system"
  put_direct_lookup_entry "monitoring" "label|release=monitoring;kube-system"
  put_direct_lookup_entry "multicluster-endpoint" "label|release=multicluster-endpoint;kube-system"
  put_direct_lookup_entry "multicluster-hub" "label|release=multicluster-hub;kube-system"
  put_direct_lookup_entry "nginx-ingress" "label|release=nginx-ingress;kube-system"
  put_direct_lookup_entry "node-problem-detector-draino" "label|release=node-problem-detector-draino;kube-system"
  put_direct_lookup_entry "nvidia-device-plugin" "label|release=nvidia-device-plugin;kube-system"
  put_direct_lookup_entry "platform-api" "label|release=platform-api;kube-system"
  put_direct_lookup_entry "platform-security-netpols" "name|networkpolicies;kube-system"
  put_direct_lookup_entry "platform-ui" "label|release=platform-ui;kube-system"
  put_direct_lookup_entry "secret-watcher" "label|release=secret-watcher;kube-system"
  put_direct_lookup_entry "security-onboarding" "name|job/security-onboarding;kube-system"
  put_direct_lookup_entry "service-catalog" "label|release=service-catalog;kube-system"
  put_direct_lookup_entry "storage-glusterfs" "label|glusterfs=daemonset;kube-system"
  put_direct_lookup_entry "system-healthcheck-service" "label|release=system-healthcheck-service;kube-system"
  put_direct_lookup_entry "tiller" "label|name=tiller;kube-system"
  put_direct_lookup_entry "unified-router" "label|k8s-app=unified-router;kube-system"
  put_direct_lookup_entry "vulnerability-advisor" "label|release=vulnerability-advisor;kube-system"
  put_direct_lookup_entry "web-terminal" "label|release=web-terminal;kube-system"
}

check_prereqs
setup_lookup_strategies

if [ "$COMMAND" == "list" ]; then
  if [ "$ACTION" == "ALL" ]; then
    echo "Known IBM Cloud Private management services:"
    get_service_names
  else
    show_help
    exit 1;
  fi
elif [ "$COMMAND" == "check" ]; then
  setup_endpoints
  setup_authz_token
  check_authz

  if [ "$ACTION" == "ALL" ]; then
    echo "IBM Cloud Private management services:"
    check_select_services "$(get_service_list)"
  elif [ "$ACTION" == "SELECT" ]; then
    echo "IBM Cloud Private management services:"
    check_select_services "$SERVICES"
  else
    show_help
    exit 1;
  fi
fi
exit $?
