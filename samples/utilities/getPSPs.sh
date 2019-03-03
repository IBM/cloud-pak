#!/bin/bash

# Copyright 2019 IBM Corporation
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#  This script displays all of the PodSecurityPolicies for the specified namespace
#  The output format is:
#    psp (<sa_name>[, <sa_name>])
#  where:
#    sa_name is the service account name in the namespace or * if the PSP applies to all SAs in the namespace

NAMESPACE=$1

if [ -z "$1" ]; then
  echo "Usage:  getPSPs.sh <namespace>"
  exit 1
fi

IFS='
'

echo "Checking PSP configuration for namespace: $NAMESPACE"
kubectl get namespace $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "Namespace $NAMESPACE does not exist."
  exit 1
fi

# Check each SA against each PSP
kubectl get psp -o name | sed "s/^.\{29\}//" | while read PSPNAME;do
  PSP=ibm-restricted-psp
  USERSFILE=$(mktemp)
  trap "rm -f $USERSFILE" EXIT

  # Check to see if a non-existing SA is authorized.
  kubectl -n $NAMESPACE --quiet=true auth can-i use podsecuritypolicy/$PSPNAME --as system:serviceaccount:$NAMESPACE:bogussa091209470982
  if [ $? -eq 0 ]; then
    echo -n "*" > $USERSFILE
  fi

  # Check each service account to see if it's authorized.
  kubectl -n $NAMESPACE get serviceaccounts -o name |  sed "s/^.\{15\}//" | while read SA;do
    kubectl -n $NAMESPACE --quiet=true auth can-i use podsecuritypolicy/$PSPNAME --as system:serviceaccount:$NAMESPACE:$SA
    if [ $? -eq 0 ]; then
        if [ -s "$USERSFILE" ]; then
          echo -n ", " >> $USERSFILE
        fi
        echo -n "$SA" >> $USERSFILE
    fi
  done
  if [ -s "$USERSFILE" ]; then
    echo "$PSPNAME ($(cat $USERSFILE))"
  fi
done
