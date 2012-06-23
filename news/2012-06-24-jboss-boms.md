---
layout: post
post_title: Introducing the JBoss BOMs 
author: pmuir
tags: [ boms ]
---

An element of JBoss Developer Framework that we haven't explored so deeply is the [JBoss BOMs](#{site.base_url}stack/jboss-bom) project. The JBoss BOMs project is where we define the recommended and tested stacks that you can use. For example, if you want to use Hibernate Search in your application, you would want to use the `jboss-javaee-6.0-with-hibernate` [stack](#{site.base_url}stack/jboss-bom/jboss-javaee-6.0-with-hibernate), which adds Hibernate to the base Java EE stack.

We define the stacks using [Maven BOMs](maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#Importing_Dependencies) (or Bill of Materials), which you can easily import into your project, defining the versions of dependencies to use. For example, if you are using Maven:

    <dependencyManagement>
        <dependencies>
	    <dependency>
	       <groupId>org.jboss.spec</groupId>
               <artifactId>jboss-javaee-web-6.0-with-hibernate</artifactId>
               <version>1.0.1.CR1</version>
               <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

Currently, we offer the base Java EE stack, add add to it [Hibernate](http://hibernate.org), [Errai](http://jboss.org/errai), [JBoss Transactions](), and tools (such as [Arquillian](http://arquillian.org)). 

You can combine the stacks. For example:

    <dependencyManagement>
        <dependencies>
	    <dependency>
	       <groupId>org.jboss.spec</groupId>
               <artifactId>jboss-javaee-web-6.0-with-hibernate</artifactId>
               <version>1.0.1.CR1</version>
               <scope>import</scope>
            </dependency>
            <dependency>
	       <groupId>org.jboss.spec</groupId>
               <artifactId>jboss-javaee-web-6.0-with-tools</artifactId>
               <version>1.0.1.CR1</version>
               <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

This should take most of the onus for managing dependencies away for you, and we plan to add more stacks. If you have a favourite stack we don't cover, then let us know!

## Roadmap

Beyond expanding the range of stacks, we are working on a [Forge](http://jboss.org/forge) plugin, allowing you to easily define the stack in use:

    jdf --stack jboss-javaee-web-6.0-with-hibernate --version 1.0.1.CR1

We also plan to add runtime compatilbity information, which will tell you the recommended stack to use with each version of [JBoss Enterprise Application Platform]() or [JBoss AS](http://jboss.org/jbossas).

## Java EE stack

The base Java EE stack is defined by the JBoss Spec project. you can [read more]().
