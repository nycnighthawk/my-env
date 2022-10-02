#!/bin/bash
PYTHON_VERSION="2.7.15"
PREFIX="/opt/python-${PYTHON_VERSION}"
LDFLAGS=-Wl,-rpath=${PREFIX}/lib ./configure --prefix=/opt/python-${PYTHON_VERSION} --enable-shared --enable-optimizations
