#!/bin/bash

# This script will create an EC2 instance

# Variables

INSTANCE_1_NAME="BashInstance1"
INSTANCE_2_NAME="BashInstance2"
INSTANCE_TYPE="t2.micro"
Key_PAIR_NAME="BashKeyPair"
AMI_ID="ami-001f2488b35ca8aad" # Ubuntu 24.04 LTS

# Create an EC2 instance

aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_PAIR_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $PUBLIC_SUBNET_1_ID \
    --region $REGION \
    --output text \
    --tag-specification 'ResourceType=instance,Tags=[{Key=Name,Value=BashInstance1}]' \
    >/dev/null

# Check if the EC2 instance was created successfully

IfFunctionFails "EC2 instance created successfully: $INSTANCE_1_NAME" "Error creating EC2 instance"
sleep 10

# Get the ID of the EC2 instance

INSTANCE_1_ID=$(
    aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].{Instance:InstanceId}' \
        --output text \
        --region "ap-southeast-2" \
        --filters "Name=tag:Name,Values=$INSTANCE_1_NAME"
)

# Check if the ID was fetched successfully

IfFunctionFails "ID fetched successfully: $INSTANCE_1_ID" "Error fetching ID"

# Get the Public IP of the EC2 instance

INSTANCE_1_PUBLIC_IP=$(
    aws ec2 describe-instances \
        --instance-ids $INSTANCE_1_ID \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        --output text \
        --region "ap-southeast-2"
)

# Check if the Public IP was fetched successfully

IfFunctionFails "Public IP fetched successfully: $INSTANCE_1_PUBLIC_IP" "Error fetching Public IP"
sleep 2
