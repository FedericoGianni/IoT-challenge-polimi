# IoT Home Challenge 5

https://github.com/FedericoGianni/iot_home_challenge_5

[Thingspeak Public channel](https://thingspeak.com/channels/1070802)

> Antoine Kryus 950120

> Diego Carletti 953280

> Federico Dei Cas 952926


## Introduction

The goal of this challenge is to link TinyOS sky motes in cooja with node-red throught a TCP socket, filter only the message of interest and then publish these messages to thingspeak throught the MQTT protocol, as shown in the scheme.

The messages contain a static topic and a random number between 0 and 100. 

![scenario](/scenario.PNG)

## Core process

### From TinyOS to node-red

![cooja](/cooja.PNG)

There are 3 motes, mote 2 and 3 both sends a message every timer ticks to mote 1. The static topic is an integer which contains the TOS_NODE_ID to differentiate the message sender. We used an integer because a topic could be also a number in form of string.

Mote 1 receives the messages and with printf it sends them throught a socket serial port which in our case was (localhost, 60001). 

### From node-red to thingspeak

![flows](/flow.PNG)

According to the flow above, node-red listen on that socket and then filters the messages. We used a single printf with some static parts to identify the data by splitting the messages by spaces with a javascript function.

Since the printf prints also some bad characters we used javascript regex to extract the right topic and random number.

Our string structure was `id: (number) random: (number)\n`
Where id is representing the static topic, and spaces were used to split the string with javascript into an array of string, and \n was used by node-red to separate messages.


We then redirected the flow from mote2 and mote3 to different thingspeak fields, and discarded messages containing a value > 70.

We also added a rate limiter to be sure that all messages will be delivered to thingspeak because it can handle only 4 messages per minute. We used a single queue to buffer the packets to avoid collisions (otherwise 2 packets in 2 different queues could be sent at the same time and one of them discarded by thingspeak).

## Simulation

To check if our project was working correctly we simulated the 3 motes in cooja and started a socket server for mote1, which was then linked to the same listening port on node-red. 

Using the debug node we could see that the messages were correctly being delivered throught the socket port and that our filter to extract the right value and select only the ones of interest was working correctly.

We then checked also on the thingspeak channel that the messages were being delivered without losses due to high publish rates.


