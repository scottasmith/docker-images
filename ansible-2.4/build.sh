#!/bin/bash

docker build -t scottsmith/ansible:2.4 .

docker image push scottsmith/ansible:2.4
