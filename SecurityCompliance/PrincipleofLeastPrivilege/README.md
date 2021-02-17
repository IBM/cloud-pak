Principle of Least Privilege

In containerized software, the follow guidance prescribes how IBM validates applications run with the least privilege as possible. 

* Run with the Red Hat restricted security context constraint 
* All product containers specify a numeric USER in their dockerfile or equivalent OCI build file for container images
* No product containers use sudo

*Run with the Red Hat restricted security context constraint*

Description: IBM products must use the restricted security context constraint (SCC). This SCC is the default given to any ServiceAccount in the OpenShift cluster. This is the most restrictive SCC shipped with Red Hat OpenShift Container Platform.  

Exposure/Risk: Containers using a different SCC would allow less isolation between containers and the host machine potentially giving unwanted access.  

Compliance Criteria: Confirmed the pod and container specifications use the restricted SCC 

*All product containers specify a numeric USER in their dockerfile or equivalent OCI build file for container images* 

 

Description:  A container created without the USER field specified in the image build file could run as the root user. 

Exposure/Risk: The container could be running with root access on the host machine. The specific access granted is determined by the definition in the security context constraint.  

Compliance Criteria: Confirmed the USER field is set in container build file 

 

* No product containers use sudo 

 

Description:  A container cannot execute commands using sudo because those commands will run on the host machine with elevated privileges.  

Exposure/Risk: A container using sudo commands can lead to executing commands on the host machine, depending on the security context constraint(SCC). 

Compliance Criteria: Confirmed by checking 2 conditions: 

sysctls to use sudo is turned off in the container 

 sudo privilege escalation is NOT used in a container image(s) 

 