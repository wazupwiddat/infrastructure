#!/bin/bash

# Check if the required parameters are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <DBMasterUsername> <DBMasterUserPassword>"
  exit 1
fi

# Set variables
STACK_NAME="shared-stack"
TEMPLATE_FILE="shared.yaml"
CERTIFICATE_ARN="arn:aws:acm:us-east-1:026450499422:certificate/390e9185-4df5-4405-89d3-38ec9e090bac"  # Replace with your actual Certificate ARN
DB_MASTER_USERNAME=$1
DB_MASTER_USER_PASSWORD=$2

# Check if stack exists
stack_exists=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].StackStatus" --output text 2>/dev/null)

if [ "$stack_exists" == "None" ]; then
  # Create the stack if it doesn't exist
  aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --parameters \
      ParameterKey=CertificateArn,ParameterValue=$CERTIFICATE_ARN \
      ParameterKey=DBMasterUsername,ParameterValue=$DB_MASTER_USERNAME \
      ParameterKey=DBMasterUserPassword,ParameterValue=$DB_MASTER_USER_PASSWORD \
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
else
  # Update the stack if it exists
  aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --parameters \
      ParameterKey=CertificateArn,ParameterValue=$CERTIFICATE_ARN \
      ParameterKey=DBMasterUsername,ParameterValue=$DB_MASTER_USERNAME \
      ParameterKey=DBMasterUserPassword,ParameterValue=$DB_MASTER_USER_PASSWORD \
    --capabilities CAPABILITY_NAMED_IAM

  # Wait for the stack to be updated
  aws cloudformation wait stack-update-complete --stack-name $STACK_NAME

  # Check if the stack update was successful
  if [ $? -eq 0 ]; then
    echo "Stack $STACK_NAME updated successfully."
  else
    echo "Failed to update stack $STACK_NAME."
    exit 1
  fi
fi

# Get the outputs of the stack
outputs=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs")

# Display the outputs
echo "Stack Outputs:"
echo $outputs | jq '.'

# Optionally save the outputs to a file
echo $outputs | jq '.' > ${STACK_NAME}-outputs.json
echo "Outputs saved to ${STACK_NAME}-outputs.json"
