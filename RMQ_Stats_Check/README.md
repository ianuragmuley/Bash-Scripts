This script is used to pull RMQ stats for SSL/Non-SSL RMQ clusters. 

You can Get below list of parameters for queues:
CONSUMER_COUNT  -  This will give you total number of consumers for queue 
TOTAL_MESSAGE_COUNT - This will display total number of message count
READY_MESSAGE_COUNT - This will display total number of ready message count
UNACKED_MESSAGE_COUNT - This will display total number of UnAcknowledged message count
RATE_PUBLISH - This will display message publish rate on queue
RATE_ACK - This will display message acknowledgement rate on queue
RATE_DELIVER -This will display message delivery rate on queue

To use this script, you would need to add RMQ credentials to /etc/environment file by adding below entries:
vi /etc/environment
export RMQ_MONITOR_USER=<RMQ-USERNAME>
export RMQ_MONITOR_PWD=<RMQ_PASSWORD>

Now edit the script and update variable "RMQ_URL" with your RMQ management console url.

Now run the script as below:
./Check_RMQ_Stats -q MyQueue -p MyParameter -c Threshold