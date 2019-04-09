%dw 1.0
%output application/json
---
{
	message: "This is a message for the JMS queue",
	queueName: p("jms.queue")
}