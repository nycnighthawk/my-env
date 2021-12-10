#!/bin/bash
rm -f /etc/alternatives/javah
rm -f /etc/alternatives/java
rm -f /etc/alternatives/javac
rm -f /etc/alternatives/javadoc
rm -f /etc/alternatives/java_sdk
rm -f /etc/alternatives/java_sdk_exports
rm -f /etc/alternatives/jre
ln -s /usr/lib/jvm/java-1.4.2-gcj-1.4.2.0/bin/javah /etc/alternatives/javah
ln -s /usr/lib/jvm/java-1.4.2-gcj-1.4.2.0/bin/java /etc/alternatives/java
ln -s /usr/lib/jvm/java-1.4.2-gcj-1.4.2.0/bin/javac /etc/alternatives/javac
ln -s /usr/lib/jvm/java-1.4.2-gcj-1.4.2.0/bin/javadoc /etc/alternatives/javadoc
ln -s /usr/lib/jvm/java-1.4.2-gcj-1.4.2.0 /etc/alternatives/java_sdk
ln -s /usr/lib/jvm/java-1.4.2-gcj-1.4.2.0/bin/jre /etc/alternatives/jre
ln -s /usr/lib/jvm-exports/java-1.4.2-gcj-1.4.2.0 /etc/alternatives/java_sdk_exports
