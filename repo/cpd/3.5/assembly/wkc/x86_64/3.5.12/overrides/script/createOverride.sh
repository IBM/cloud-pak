#!/bin/sh
set -e
# Prerequisites is user must login to oc machine before executing this script to default namespace
usage() {
  echo "Usage $0 <FSType[nfs/ocs/portworx]> <UpgradeType[CPD_250_301_350/CPD_300_301_350]>"
  echo "e.x. $0 ocs CPD_300_301_350"
  exit 1
}

checkUsage() {
  if [ $# -ne 2 ]; then
    echo "Incomplete parameters $#"
    usage
  fi

  fsType=${1}
  upgradeType=${2}

  if [ -z ${fsType} ]; then
    usage
  fi
  if [ -z ${upgradeType} ]; then
    usage
  fi
  if [  ${fsType} != "nfs" -a ${fsType} != "ocs" -a ${fsType} != "portworx" ]; then
    usage
  fi
  if [ ${upgradeType} != "CPD_250_301_350" -a ${upgradeType} != "CPD_300_301_350" -a ${upgradeType} != "CPD_301_350" -a ${upgradeType} != "CPD_350" ]; then
    usage
  fi

}


processTemplate() {

  echo "Parsing ${OVERRIDE_TEMPLATE} for parameters ${fsType} ${upgradeType} & Creating ${OVERRIDE_FILE}"
  echo "## Generated using template ${OVERRIDE_TEMPLATE} with parameters ${fsType} ${upgradeType}" > ${OVERRIDE_FILE}
  fs=f
  up=f
  # unset IFS to retain spaces in lines
  IFS=
  while read -r line
  do {
	# Check FSTYPE
    isFS=`echo $line | sed "s/^\(#FSTYPE\) .*$/\1/g"`
    if [ "${isFS}" == "#FSTYPE" ]; then
      isFS=`echo $line | sed "s/^#FSTYPE .*\($fsType\).*$/\1/g"`
      if [ "${isFS}" == "${fsType}" ]; then
        fs=t
      else
        fs=f
      fi
      continue
    fi

    # Check UPTYPE / Upgrade Type
    isUP=`echo $line | sed "s/^\(#UPTYPE\) .*$/\1/g"`
    if [ "${isUP}" == "#UPTYPE" ]; then
      isUP=`echo $line | sed "s/^#UPTYPE .*\($upgradeType\).*$/\1/g"`
      isIgnoreForFS=`echo $line | sed "s/^#UPTYPE .*\($upgradeType\)[^,]*-\($fsType\).*$/\1-\2/g"`
      if [ "${isUP}" == "${upgradeType}" -a "${isIgnoreForFS}" != "${upgradeType}-${fsType}" ]; then
        up=t
      else
        up=f
      fi
      continue
    fi

    # Check if need to replace value from oc pvc definition
    if [ "${fs}" == "t" -a "${up}" == "t" ]; then
      isOCReplace=`echo $line | sed "s/.*\(OC_REPLACE\).*$/\1/g"`
      if [ "${isOCReplace}" == "OC_REPLACE" ]; then
        ocReplace=`echo $line | sed "s/\(.*\)OC_REPLACE\(.*\)$/\1\2/g"`
        ymlKey=`echo $ocReplace | cut -d '|' -f 1`
        pvcName=`echo $ocReplace | cut -d '|' -f 2`
        ymlPath=`echo $ocReplace | cut -d '|' -f 3`
        if [ ! -z "${pvcName}" -a ! -z "${ymlPath}" ]; then
          ymlValue="`oc get pvc --no-headers -o custom-columns=${ymlPath} ${pvcName}`"
          ocStatus=$?
          echo $line | sed "s/\(.*\)OC_REPLACE.*/\1$ymlValue/g" >> ${OVERRIDE_FILE}
          continue
        fi
      fi
      echo "$line" >> ${OVERRIDE_FILE}
    fi
  }
  done < ${OVERRIDE_TEMPLATE}
  echo "Done, Check ${OVERRIDE_FILE}"
}

BASEDIR=$(dirname "$0")
OVERRIDE_TEMPLATE=${BASEDIR}/override.template.yaml
OVERRIDE_FILE=override.yaml
############################
###     MAIN Program :
############################

checkUsage $@
processTemplate
