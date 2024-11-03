#!/bin/bash

# This script will create a key pair and store the private key in a file

# Variables

KEY_PAIR_NAME="BashKeyPair"
KEY_PAIR_FILE="BashKeyPair.pem"

# Create a Key Pair

KEY_PAIR_VALUE=$(
    aws ec2 create-key-pair \
        --key-name $KEY_PAIR_NAME \
        --query 'KeyMaterial' \
        --region "ap-southeast-2" \
        --output text

)

# Check if the Key Pair was created successfully

IfFunctionFails "Key Pair created successfully: $KEY_PAIR_NAME" "Error creating Key Pair"
sleep 2

# Store the private key in a file

echo "$KEY_PAIR_VALUE" >$(pwd)/$KEY_PAIR_FILE

# Check if the private key was stored in the file

IfFunctionFails "Private key stored in file: $KEY_PAIR_FILE" "Error storing private key in file"
sleep 2

# Change the permissions of the private key file

chmod 400 $(pwd)/$KEY_PAIR_FILE

# Display the success message

echo "Key Pair created successfully with private key stored in file: $KEY_PAIR_FILE"
