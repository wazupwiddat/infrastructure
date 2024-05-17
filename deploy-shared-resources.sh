#!/bin/bash

# Set variables
STACK_NAME="shared-stack"
TEMPLATE_FILE="shared.yaml"
CERTIFICATE_ARN="arn:aws:acm:us-east-1:026450499422:certificate/390e9185-4df5-4405-89d3-38ec9e090bac"  # Replace with your actual Certificate ARN

# Create the stack
aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$TEMPLATE_FILE \
  --parameters ParameterKey=CertificateArn,ParameterValue=$CERTIFICATE_ARN \
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

# Optionally save the outputs to a file
echo $outputs | jq '.' > stack-outputs.json
