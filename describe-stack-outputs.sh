#!/bin/bash

# Check if stack name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <stack-name>"
  exit 1
fi

# Set variables
STACK_NAME=$1

# Describe the stack and get the outputs
outputs=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs")

# Check if the command was successful
if [ $? -eq 0 ]; then
  echo "Stack Outputs for $STACK_NAME:"
  echo $outputs | jq '.'
else
  echo "Failed to describe stack $STACK_NAME."
  exit 1
fi

# Optionally save the outputs to a file
echo $outputs | jq '.' > "${STACK_NAME}-outputs.json"
echo "Outputs saved to ${STACK_NAME}-outputs.json"
