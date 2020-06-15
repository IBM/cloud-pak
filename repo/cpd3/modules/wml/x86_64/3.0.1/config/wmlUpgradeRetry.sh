#!/bin/bash
#****************************************************************
# IBM Confidential
#
# OCO Source Materials
#
# Watson Machine Learning
#
# (c) Copyright IBM Corp. 2020
#
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office.
#*****************************************************************

usage() {
        echo "Usage: "
        echo "./wml-upgrade.sh --space-list space1,space2 --project-list project1,project2 --name-space ns1"
        echo "./wml-upgrade.sh --space-list space1,space2 --name-space ns1"
        echo "./wml-upgrade.sh --project-list project1,project2 --name-space ns1"
        exit
}

clean_files() {
	if [[ -e $file ]] ; then
		rm -f $file
	fi

	if [[ -e $patchfile1 ]] ; then
		rm -rf $patchfile1
	fi

	if [[ -e $patchfile2 ]] ; then
		rm -rf $patchfile2
	fi
}

remove_unwanted_lines() {
        oc get job pre-upgrade-migrate-cams-assets -n $NAME_SPACE -o yaml > $file

	sed -i '/creationTimestamp/d' $file
	sed -i '/resourceVersion/d' $file
	sed -i '/selfLink/d' $file
	sed -i '/uid/d' $file
	sed -i '/matchLabels/d' $file
	sed -i '/controller-uid/d' $file
	sed -i '/status/d' $file
	sed -i '/completionTime/d' $file
	sed -i '/conditions/d' $file
	sed -i '/lastProbeTime/d' $file
	sed -i '/lastTransitionTime/d' $file
	sed -i '/startTime/d' $file
	sed -i '/succeeded/d' $file
	sed -i '/type: Complete/d' $file
	sed -i '/active/d' $file
}

create_job() {
	sleep 5
	oc delete job pre-upgrade-migrate-cams-assets -n $NAME_SPACE

	echo "        - name: UPGRADE_PROJECT_LIST" > /tmp/patch1.txt
	echo "          value: $PROJECT_LIST" >> /tmp/patch1.txt
	sed -i "/env:/r /tmp/patch1.txt" $file

	echo "        - name: UPGRADE_SPACE_LIST" > /tmp/patch2.txt
	echo "          value: $SPACE_LIST" >> /tmp/patch2.txt
	sed -i "/env:/r /tmp/patch2.txt" $file

	oc create -f $file -n $NAME_SPACE
}


# start here
while :; do
     case $1 in
         --space-list) SPACE_LIST=$2 ; shift ;;
         --project-list) PROJECT_LIST=$2 ; shift ;;
         --name-space) NAME_SPACE=$2 ; shift ;;
	 --help) usage ; shift ;;
         *)  break
     esac
     shift
done

echo "|--------------- Starting pre-upgrade-job to upgrade assets in the input projects/spaces"
echo ""

#echo $SPACE_LIST
#echo $PROJECT_LIST
#echo $NAME_SPACE

file=/tmp/wml-job.yaml
patchfile1=/tmp/patch1.txt
patchfile2=/tmp/patch2.txt

clean_files
remove_unwanted_lines
create_job
echo ""
echo "|--------------- Please monitor logs of pod associated with the job 'pre-upgrade-migrate-cams-assets' for progress"