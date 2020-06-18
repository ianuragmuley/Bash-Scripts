#!/bin/bash
DATA=$(kubectl get deploy -o jsonpath='{range .items[*]}{@.metadata.name}{"|"}{@.status.unavailableReplicas}{"|"}{@.status.replicas}{"\n"}{end}' | awk -F"|"  '$2!=""')
while IFS="|" read DEPLOY FAIL_COUNT TOTAL_PODS
do
DEPLOY_PODNAMES=$(kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods |  python -m json.tool | jq -r '.items[] | .containers[].name + "|" + .metadata.name')
POD_LIST=$(echo "$DEPLOY_PODNAMES" | awk -v var="$DEPLOY" -F"|" '$1==var {print $2}' | xargs | sed -e 's/ /|/g')
if [ -z "$POD_LIST" ]
then
      echo "$DEPLOY : Critical. Unavailable pods: $FAIL_COUNT . Total Expected Pod Count: $TOTAL_PODS"
else
      POD_NOT_RUNNING=$(kubectl get po | grep -v STATUS | egrep $POD_LIST |awk '$3!="Running"{print "pod:"$1"|state:"$3}')
      if [ -z "$POD_NOT_RUNNING" ]
      then
          CONTAINER_NOT_RUNNING=$(kubectl get pods| egrep $POD_LIST | awk '{print $1"/"$2"/"$3}' | awk -F"/" '$2!=$3{print $1 "|Container Status:"$2"/"$3}')
          if [ -z "$CONTAINER_NOT_RUNNING" ]
          then
              echo "$DEPLOY : Pending/Faulty Pod Count: $FAIL_COUNT / $TOTAL_PODS"
          else
              echo "$DEPLOY :" $CONTAINER_NOT_RUNNING
          fi
          else
              echo "$POD_NOT_RUNNING"
          fi
fi
done <<< "$DATA"