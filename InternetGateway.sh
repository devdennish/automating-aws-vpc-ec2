#!/bin/bash

# This script will create an Internet Gateway and attach it to the VPC

# Variables

IGW_NAME="BashIGW"

# Create an Internet Gateway and store the ID in a variable

INTERNET_GATEWAY_ID=$(
    aws ec2 create-internet-gateway \
        --region "ap-southeast-2" \
        --query 'InternetGateway.InternetGatewayId' \
        --output text
)

# Check if the Internet Gateway was created successfully

IfFunctionFails "Internet Gateway created successfully with ID: $INTERNET_GATEWAY_ID" "Error creating Internet Gateway"

# Attach the Internet Gateway to the VPC

aws ec2 attach-internet-gateway \
    --internet-gateway-id $INTERNET_GATEWAY_ID \
    --vpc-id $VPC_ID \
    --region "ap-southeast-2"

# Check if the Internet Gateway was attached successfully

IfFunctionFails "Internet Gateway attached successfully to VPC: $VPC_NAME" "Error attaching Internet Gateway to VPC"

# Name the Interet Gateway

CreateTags $INTERNET_GATEWAY_ID $IGW_NAME "ap-southeast-2"

# Check if the Internet Gateway was named successfully

IfFunctionFails "Internet Gateway named successfully: $IGW_NAME" "Error naming Internet Gateway"
