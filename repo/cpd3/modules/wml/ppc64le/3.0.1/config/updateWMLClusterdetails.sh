#!/bin/bash
# echo "*************************************"	
# echo "Enter host, port, default_instance_group and default_instance_group_edt "
# echo "*************************************"

if [ $# -ne 5 ]; then
	echo "Usage : $0  host port default_instance_group  default_instance_group_edt IP-ADDRESS"
	exit 1
	
fi
	
    DEFAULT_INSTANCE_GROUP_EDT=$4
    DEFAULT_INSTANCE_GROUP=$3
    PORT=$2
    HOST=$1
    IP_ADDRESS=$5

NS="${NAMESPACE:-zen}"

##Form EXTERNAL_URL
external_url="https://${IP_ADDRESS}"
echo
echo

#patch the existing wmltrainingconfigmap using the below command

host=\"$HOST\"
port=\"$PORT\"
default_instance_group=\"$DEFAULT_INSTANCE_GROUP\"
default_instance_group_edt=\"$DEFAULT_INSTANCE_GROUP_EDT\"
url=\"${external_url}\"

patch_res=$(kubectl patch configmap wmltrainingconfigmap --type merge -p="{\"data\":{\"host\":${host}, \"port\":${port}, \"default_instance_group\":${default_instance_group},\"default_instance_group_edt\":${default_instance_group_edt}, \"external_url\":${url}}}" -v=1 -n ${NS})
echo ***PATCH RESULT STATUS******
echo $patch_res
echo 
echo 

echo ***********RESTARTING TRAINING PODS***************
 kubectl delete pods -n $NS -l app=wmltraining
 kubectl delete pods -n $NS -l app=wmltrainingorchestrator
echo ***********TRAINING PODS RESTARTED*****************
echo
echo
echo
echo ***********RESTARTING PORTAL PODS***************
 kubectl delete pods -n $NS -l app=portal-main
 kubectl delete pods -n $NS -l app=portal-ml-dl
echo ***********PORTAL PODS RESTARTED*****************
echo
echo
echo

# Validate the new configmaps are reflecting in the training pods.
echo ************VALIDATING CHANGES*****************************
PODS="$(kubectl get pods -n $NS| grep training | cut -d\  -f1 )"

   for P in $PODS
   do
      count=$(kubectl exec -it $P  -n $NS env| grep WMLA | wc -l)
      
      if [ "$count" != 4 ];then
     	 echo "Found ${count} WMLA_* variables instead of 4"
      	 exit 0
      fi


      hostValue=$(kubectl exec -it $P -n $NS env| grep WMLA_HOST| cut -d "=" -f 2| tr -d '\r')
      portValue=$(kubectl exec -it $P -n $NS env| grep WMLA_PORT| cut -d "=" -f 2 | tr -d '\r')
      instGroupValue=$(kubectl exec -it $P -n $NS env| grep WMLA_DEFAULT_INSTANCE_GROUP= | cut -d "=" -f 2| tr -d '\r')
      instGroupValueEDT=$(kubectl exec -it $P -n $NS env| grep WMLA_DEFAULT_INSTANCE_GROUP_EDT| cut -d "=" -f 2|tr -d '\r')
      externalUrl=$(kubectl exec -it $P -n $NS env| grep WML_EXTERNAL_URL| cut -d "=" -f 2 | tr -d '\r')
      echo
      echo

      echo "******************************************************"
      echo "Kube Configmaps validation started for pod $P"
      echo

      if [ "$hostValue" != "$HOST" ];then
      	echo "Host values does not match in pod $P"
      	exit 0
      fi
      
      if [ "$portValue" != "$PORT" ];then
      	echo "Port value does not match in pod $P"
      	exit 0
      fi
      
      if [ "$instGroupValue" != "$DEFAULT_INSTANCE_GROUP" ];then
      	echo "Default instance group value does not match in pod $P"
     	exit 0
      fi
      
      if [ "$instGroupValueEDT" != "$DEFAULT_INSTANCE_GROUP_EDT" ];then
      	echo "Default instance group edt  value does not match in pod $P"
      	exit 0
      fi

      if [ "$externalUrl" != "$external_url" ];then
            echo "externalUrl value does not match in pod $P"
            exit 0
      fi

      echo "Config patch validated successfully for pod $P"
  done

    echo
    echo
    echo
    echo ************VALIDATING PORTAL-MAIN POD  CHANGES*****************************
    PODS="$(kubectl get pods -n $NS| grep portal-main | cut -d\  -f1 )"

    for P in $PODS
       do
          count=$(kubectl exec -it $P  -n $NS env| grep WMLA_HOST | wc -l)

          if [ "$count" != 1 ];then
             echo "WMLA_HOST not present in as env variable for pod $P"
             exit 0
          fi


          hostValue=$(kubectl exec -it $P -n $NS env| grep WMLA_HOST| cut -d "=" -f 2| tr -d '\r')

          if [ "$hostValue" != "$HOST" ];then
            echo "Host values does not match in pod $P"
            exit 0
          fi
         echo
         echo
         echo "Config patch validated successfully for pod $P"

        done

    echo
    echo
    echo ************VALIDATING PORTAL-ML_DL POD  CHANGES*****************************
    PODS="$(kubectl get pods -n $NS| grep portal-ml-dl | cut -d\  -f1 )"

    for P in $PODS
       do
          count=$(kubectl exec -it $P  -n $NS env| grep WMLA_HOST | wc -l)

          if [ "$count" != 1 ];then
             echo "WMLA_HOST not present in as env variable for pod $P"
             exit 0
          fi


          hostValue=$(kubectl exec -it $P -n $NS env| grep WMLA_HOST| cut -d "=" -f 2| tr -d '\r')

          if [ "$hostValue" != "$HOST" ];then
            echo "Host values does not match in pod $P"
            exit 0
          fi

            echo
    echo
    echo "Config patch validated successfully for pod $P"
    echo
    echo

       done

