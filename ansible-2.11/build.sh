#!/bin/bash

docker build -t scottsmith/ansible:5.2.0 .

docker image push scottsmith/ansible:5.2.0
