#!/bin/bash

# This script will create a security group and add rules to it.

# Variables

SECURITY_GROUP_NAME="BashScriptSecurityGroup"
DESCRIPTION="Security Group created by Bash Script"

# Create a Security Group

SecurityGroup() {
    aws ec2 create-security-group \
        --group-name $SECURITY_GROUP_NAME \
        --description "$DESCRIPTION" \
        --query 'GroupId' \
        --region $REGION \
        --vpc-id $VPC_ID \
        --output text

}

SECURITY_GROUP_ID=$(SecurityGroup)

IfFunctionFails "Security Group created successfully" "Error creating Security Group"
sleep 2

# Add rules to the security group

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --ip-permissions file://Ingress.json \
    --region $REGION \
    >/dev/null

IfFunctionFails "Ingress rule added successfully" "Error adding Ingress rule"
sleep 2
