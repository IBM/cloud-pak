## Steps to execute the script

This script is used to auto-generate the WKC install/upgrade override files for different storage classes and releases.
Prerequisites is user must login to oc machine before executing this script to default namespace.

```
Usage ./createOverride.sh <FSType[NFS/OC43/PORTWORX240/PORTWORX250]> <UpgradeType[CPD_250_301_350/CPD_300_301_350/CPD_301_350]>
or
Usage ./createOverride.sh <FSType[OC43/PORTWORX250]> <InstallType[CPD_350]>
e.x. ./createOverride.sh OC43 CPD_300_301_350
e.x. ./createOverride.sh OC43 CPD_350
```