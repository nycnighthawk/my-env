#!/bin/bash
rm -f /etc/alternatives/javah
rm -f /etc/alternatives/java
rm -f /etc/alternatives/javac
rm -f /etc/alternatives/javadoc
rm -f /etc/alternatives/java_sdk
rm -f /etc/alternatives/jre
rm -f /etc/alternatives/java_sdk_exports
ln -s /usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/bin/javah /etc/alternatives/javah
ln -s /usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/bin/java /etc/alternatives/java
ln -s /usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/bin/javac /etc/alternatives/javac
ln -s /usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/bin/javadoc /etc/alternatives/javadoc
ln -s /usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0 /etc/alternatives/java_sdk
ln -s /usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/jre /etc/alternatives/jre
ln -s /usr/lib/jvm-exports/java-1.6.0-openjdk-1.6.0.0 /etc/alternatives/java_sdk_exports
