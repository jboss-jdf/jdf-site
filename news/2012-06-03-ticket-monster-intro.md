---
layout: post
post_title: Intro to TicketMonster 
author: mbogoevici
tags: [ ticketmonster ]
---

For a hands-on approach on getting familiar with the JBoss Developer Framework, you should get started with our showcase application, TicketMonster. You can find it running in the cloud on openshift [here](http://ticketmonster-jdf.rhcloud.com), you can download it from this site, or you can fork it on GitHub.

![TicketMonster Splash](#{site.base_url}/images/ticket-monster-splash-2.png)

What's the goal?
----------------

Quickstarts are an excellent way for introducing narrowly focused topics. At the same time, making the most of JBoss and Java EE 6 technologies on JBoss Enterprise Application Platform and JBoss AS also requires getting them to work together in an optimal way. So a broader, more elaborate example was required.

Enter [TicketMonster](#{site.base_url}/examples/get-started). Based on an online ticketing business scenario, the demo application of the JBoss Developer Framework shows you how to combine the power of Java EE 6 with a choice of three different UI layer technologies: HTML5+REST, Richfaces/JSF and GWT/Errai. It also shows you how to build applications optimized for desktop as well as mobile clients.

The business domain of the application is rich, and there are plenty of use cases to cover, ranging from the end-users requirements of being able to find events and book tickets easily, to the administrators' need of managing the master data of the application: events, venues, ticket prices, and monitoring the status of ticket sales. 

As such, we use the three architecture variants to implement various parts of the application:

* HTML5+REST is used for creating a flexible, desktop and mobile ready user site;
* Richfaces/JSF is used together with Forge for rapidly creating a CRUD administration site;
* Errai/GWT is used for creating a monitoring console that can receive notifications about server-side changes via CDI events.

Not only do these three technologies complement each other, but they also illustrate how the various parts of the application can jell together, consuming a common set of services and interacting through powerful Java EE mechanisms such as CDI eventing. 

So there it is, a working example. But, what can you do with it?

Try it out
----------

Seeing is believing! You can see the example running [in the cloud](http://ticketmonster-jdf.rhcloud.com) or you can check it out from [GitHub](http://github.com/jboss-jdf/ticket-monster) and run it locally.

Learn with it
-------------

Seeing the application at work is great, but understanding how it has been put together is better! To that end, we have created a series of tutorials that retrace our steps, showing you not only the mechanics but also the reasoning behind the design decisions! 

Make it your own
----------------

Did we say check it out? We did, and we actually meant 'fork it'! Re-creating TicketMonster is a great venue for learning, but you can getting much further than we did. We would love to see you using TicketMonster as a starting point for trying out new technologies, or expanding it with you own use cases. Everything is put in place for that.

That's all that there is?
-------------------------

Actually, not. TicketMonster will be updated with each release of the JBoss Developer Framework. We have [great plans for the future](#{site.base_url}/about/roadmap). 

At the same time, feel free to contribute! As you saw earlier, one of TicketMonster's goals is to enable you to write your own demos based on it. If you would like to share them vit 



