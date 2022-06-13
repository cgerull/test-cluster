#!/bin/sh
#
# Get root token from standalone dev server.

# 
#  -policy=mytest
kubectl exec -n vault vault-0  -- vault token create -policy=mytest | grep "^token\s" | awk -F '  +' '{print $2}'