#!/bin/bash

command -v apt &> /dev/null && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    apt-get -y autoremove

command -v yum &> /dev/null && \
    yum -y update

