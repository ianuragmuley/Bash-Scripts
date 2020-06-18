#!/bin/bash
# function to help the user out with the usage of this script
source /etc/environment
usage() {
 echo -e "Usage: $0 \n -q <QUEUE_NAME> \tSelect Queue name. List the queue name, if required (Mandatory)\n -p <PARAMETER_NAME> \tSelect Any of these Queue parameters CONSUMER_COUNT, TOTAL_MESSAGE_COUNT, READY_MESSAGE_COUNT, UNACKED_MESSAGE_COUNT, RATE_PUBLISH, RATE_ACK, RATE_DELIVER (Mandatory)\n -l all \tTo list all queues except mfa queues (Optional)\n -c <int> \tTo set critical alert threshold \n -h <help> \tDisplays this help message\n\n Example Usage: $0 -q MyQueue -p MyParameter -c Threshold" 1>&2;
 exit 3;
}
RMQ_URL=https://<YOUR-RMQ-URL>:<PORT>
# check for command line arguments
while getopts "q:p:h:l:c:" option; do
 case "${option}" in
  q) QUEUE_NAME=${OPTARG};;
  p) PARAMETER=${OPTARG};;
  l) LIST=1;;
  c) CRIT_THRESHOLD=${OPTARG};;
  h) usage;;
  *) usage;;
 esac
done
if [[ $# -eq 0 ]] ; then
  usage
  exit 1
fi
if [ -z "${LIST}" ]; then
 echo "Not Listing queues." > /dev/null
else
 echo "Listing All Queues (except mfa queues)"
  curl --silent -k -u $RMQ_MONITOR_USER:$RMQ_MONITOR_PWD $RMQ_URL/api/queues/ | jq -r '.[].name' | grep -v mfa
  exit 0
fi
if [ -z "${QUEUE_NAME}" ]; then
 echo "No Queue Name To Select"
 exit 1
else
 echo "Selected Queue: $QUEUE_NAME" > /dev/null
fi
if [ -z "${PARAMETER}" ]; then
 echo No Queue Parameter Selected
 exit 1
else
 echo "showing $PARAMETER for $QUEUE_NAME" > /dev/null
fi
if [ -z "${CRIT_THRESHOLD}" ]; then
 echo "No Critical Threshold Set"
 exit 1
else
 echo "Critical threshold set to $CRIT_THRESHOLD" > /dev/null
fi
QUEUE_STATS=$(curl --silent -k -u $RMQ_MONITOR_USER:$RMQ_MONITOR_PWD $RMQ_URL/api/queues/%2F/$QUEUE_NAME | jq -r '.')
CONSUMER_COUNT=$(echo "$QUEUE_STATS" | jq -r '.consumers')
TOTAL_MESSAGE_COUNT=$(echo "$QUEUE_STATS" | jq -r '.messages')
READY_MESSAGE_COUNT=$(echo "$QUEUE_STATS" | jq -r '.messages_ready')
UNACKED_MESSAGE_COUNT=$(echo "$QUEUE_STATS" | jq -r '.messages_unacknowledged')
RATE_PUBLISH=$(echo "$QUEUE_STATS" | jq -r '.message_stats.publish_details.rate')
RATE_ACK=$(echo "$QUEUE_STATS" | jq -r '.message_stats.ack_details.rate')
RATE_DELIVER=$(echo "$QUEUE_STATS" | jq -r '.message_stats.deliver_details.rate')
if [ "$PARAMETER" == "CONSUMER_COUNT" ]; then
    #echo "CONSUMER_COUNT is $CONSUMER_COUNT"
        VAL_2_MEASURE=$CONSUMER_COUNT
elif [ "$PARAMETER" == "TOTAL_MESSAGE_COUNT" ]; then
    #echo "TOTAL_MESSAGE_COUNT is $TOTAL_MESSAGE_COUNT"
        VAL_2_MEASURE=$TOTAL_MESSAGE_COUNT
elif [ "$PARAMETER" == "READY_MESSAGE_COUNT" ]; then
    #echo "READY_MESSAGE_COUNT is $READY_MESSAGE_COUNT"
        VAL_2_MEASURE=$READY_MESSAGE_COUNT
elif [ "$PARAMETER" == "UNACKED_MESSAGE_COUNT" ]; then
    #echo "UNACKED_MESSAGE_COUNT is $UNACKED_MESSAGE_COUNT"
        VAL_2_MEASURE=$UNACKED_MESSAGE_COUNT
elif [ "$PARAMETER" == "RATE_PUBLISH" ]; then
    #echo "RATE_PUBLISH is $RATE_PUBLISH"
        VAL_2_MEASURE=$RATE_PUBLISH
elif [ "$PARAMETER" == "RATE_ACK" ]; then
    #echo "RATE_ACK is $RATE_ACK"
        VAL_2_MEASURE=$RATE_ACK
elif [ "$PARAMETER" == "RATE_DELIVER" ]; then
    #echo "RATE_DELIVER is $RATE_DELIVER"
        VAL_2_MEASURE=$RATE_DELIVER
else
echo "Nothing to show / Error"
fi
#echo $VAL_2_MEASURE $PARAMETER
if [ 1 -eq "$(echo "${CRIT_THRESHOLD} < ${VAL_2_MEASURE}" | bc)" ]
then
  echo "CRITICAL: Value of $PARAMETER i.e. $VAL_2_MEASURE is greater than threshold i.e. $CRIT_THRESHOLD"
else
  echo "OK: Value of $PARAMETER i.e. $VAL_2_MEASURE is less than threshold i.e. $CRIT_THRESHOLD"
fi