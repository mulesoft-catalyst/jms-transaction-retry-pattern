# JMS Transaction with rollback and retry pattern

## Description

This is a common real use case where customers want to implement a JMS queue from where messages will be read, and then processed. If in the middle of the process the message would fail, this use case contemplates a rollback situation using the JMS Transaction, retrying the message X amount of times and after the retry is exhausted, it inserts the message into a Dead Letter Queue (DQL). Should what was making the process to fail gets fixed, one can go and run the flow (poll) manually to re-insert the message into the original queue and process it again.

Bear in mind this process was based in ActiveMQ
## Guide

#### 01 - Flows explanation

In the application there are 3 flows.

The **first flow** is used to insert a message into the JMS queue.   
The **second flow** is used to read a message from the JMS Queue.  
The **third flow** is used to re-insert a message into the JMS queue, when there are messages in the DLQ.


In the **second flow**, there is a Groovy element that is used to throw an exception manually in order to fail the process of the message obtained from the JMS queue.   
If you wish to just test the happy path, you can comment this element in the XML code.

#### 02 - Execute the flows and reproduce the use case

The following are the steps to reproduce the use case:

- First of all, you should install and run an Active MQ instance. You can do that either running it using Docker, or you can follow instructions on [this link](https://wiki.corp.mulesoft.com/display/SVCS/Active+MQ+Tips+and+Tricks#ActiveMQTipsandTricks-LocalInstallation)
- Change the config.local.properties file for pointing the ActiveMQ instance to yours
- Run the application in debug mode. You will probably want to put some breakpoints to see how the use case is reproduced
- Run the poll on the flow called "put-jms-message-to-queue-implementation-flow". It should insert the message into the queue called **MyQueue**
- After that is done, the flow called "read-jms-message-implementation-flow" should execute automatically, as it will read a message from the JMS queue **MyQueue**
- When the message is executed, it will go into the Groovy Exception script and fail
- As a result, the rollback strategy will be executed and the message will be retried as many times as it is defined in the config.local.properties
- When the retries are exhausted, the message will be delivered to the DLQ
- If you want to put your DLQ message into the original queue, run the poll on the flow called "dead-letter-queue-implementation-flow"
