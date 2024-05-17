#!/bin/bash

# Set variables
HOSTED_ZONE_ID="Z03380123T9VQI8XDXH71"
ALB_DNS_NAME="shared-s-ALB-PJllIXoM09eh-432430191.us-east-1.elb.amazonaws.com"
STACK_NAME="subdomain-stack"
TEMPLATE_FILE="subdomain.yaml"

# Create the stack
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$TEMPLATE_FILE \
  --parameters \
    ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
    ParameterKey=ALBDNSName,ParameterValue=$ALB_DNS_NAME \
  --capabilities CAPABILITY_NAMED_IAM

# Wait for the stack to be created
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME

# Check if the stack creation was successful
if [ $? -eq 0 ]; then
  echo "Stack $STACK_NAME created successfully."
else
  echo "Failed to create stack $STACK_NAME."
  exit 1
fi

# Get the outputs of the stack
outputs=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs")

# Display the outputs
echo "Stack Outputs:"
echo $outputs | jq '.'

# Optionally save the outputs to a file
echo $outputs | jq '.' > "${STACK_NAME}-outputs.json"
echo "Outputs saved to ${STACK_NAME}-outputs.json"
