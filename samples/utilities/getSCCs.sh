#!/bin/bash
# Copyright 2019 IBM Corporation
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#  This script displays all of the SecurityContextConstraints for the specified namespace/project
#  The output format is:
#    scc (<sa_name>[, <sa_name>])
#  where:
#    sa_name is the service account name in the namespace or * if the SCC applies to all SAs in the namespace
#  This script displays all of the SecurityContextConstraints for the specified namespace
#  The output format is:
#    scc (<sa_name>[, <sa_name>])
#  where:
#   sa_name is the service account name in the namespace or * if the SCC applies to all SAs in the namespace
#   *sys:sa:ns is the system:serviceaccounts:<namespace> group.  All service accounts in the namespace.
#   *sys:auth the system:authenticated group.  All authenticated users.
#   *sys:sa the system:serviceaccounts group.  All service accounts

NAMESPACE=$1

if [ -z "$1" ]; then
  echo "Usage:  getSCCs.sh <namespace>"
  exit 1
fi

IFS='
'

echo "Checking SCC configuration for namespace: $NAMESPACE"
kubectl get namespace $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
  echo "Namespace $NAMESPACE does not exist."
  exit 1
fi


kubectl get scc -o name | while read SCC;do
  SCCNAME="$(echo $SCC | cut -d'/' -f2)"
  USERSFILE=$(mktemp)
  trap "rm -f $USERSFILE" EXIT


    # Find all groups from the current SCC
    kubectl get $SCC -o jsonpath='{range .groups[*]}{@}{"\n"}{end}' | while read line;do 
      # Check to see if the service account namespace is in the name
      GROUPNS="$line"
      if [ "$GROUPNS" = "system:serviceaccounts:$NAMESPACE" ]; then
        if [ -s "$USERSFILE" ]; then
          echo -n ", " >> $USERSFILE
        fi
        echo -n "*sys:sa:ns" > $USERSFILE
      elif [ "$GROUPNS" = "system:authenticated" ]; then
        if [ -s "$USERSFILE" ]; then
          echo -n ", " >> $USERSFILE
        fi
        echo -n "*sys:auth" > $USERSFILE
      elif [ "$GROUPNS" = "system:serviceaccounts" ]; then
        if [ -s "$USERSFILE" ]; then
          echo -n ", " >> $USERSFILE
        fi
        echo -n "*sys:sa" > $USERSFILE
      fi
    done

    # Find all users from the current SCC
    kubectl get $SCC -o jsonpath='{range .users[*]}{@}{"\n"}{end}' | while read line;do 
      # Check to see if the service account namespace is in the name
      USERNS="$(echo $line | cut -d':' -f1,2,3)"
      if [ "$USERNS" = "system:serviceaccount:$NAMESPACE" ]; then
        SA="$(echo $line | cut -d':' -f4)"
        if [ -s "$USERSFILE" ]; then
          echo -n ", " >> $USERSFILE
        fi
        echo -n "$SA" >> $USERSFILE
      fi
    done

    if [ -s "$USERSFILE" ]; then
      echo "$SCCNAME ($(cat $USERSFILE))"
    fi
done
