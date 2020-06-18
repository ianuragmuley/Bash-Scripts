This script is used to pull RMQ stats for SSL/Non-SSL RMQ clusters.

You can Get below list of parameters for queues: 
<li>CONSUMER_COUNT  -  This will give you total number of consumers for queue </li>
<li>TOTAL_MESSAGE_COUNT - This will display total number of message count </li>
<li>READY_MESSAGE_COUNT - This will display total number of ready message count </li>
<li>UNACKED_MESSAGE_COUNT - This will display total number of UnAcknowledged message count </li>
<li>RATE_PUBLISH - This will display message publish rate on queue </li>
<li>RATE_ACK - This will display message acknowledgement rate on queue </li>
<li>RATE_DELIVER -This will display message delivery rate on queue </li>

To use this script, you would need to add RMQ credentials to /etc/environment file by adding below entries:
<li>vi /etc/environment </li>
export RMQ_MONITOR_USER=<RMQ-USERNAME>
export RMQ_MONITOR_PWD=<RMQ_PASSWORD>

Now edit the script and update variable "RMQ_URL" with your RMQ management console url.

Now run the script as below:
<li>./Check_RMQ_Stats -q MyQueue -p MyParameter -c Threshold </li>