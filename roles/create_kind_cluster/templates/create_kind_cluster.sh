#!/bin/bash

CLUSTER_NAME="{{ kind_cluster_name }}"

if ! kind get clusters | grep -q "^$CLUSTER_NAME$"; then
  echo "Creating Kind cluster $CLUSTER_NAME..."
  kind create cluster --name $CLUSTER_NAME
else
  echo "Kind cluster $CLUSTER_NAME already exists."
fi
