#!/bin/bash

# Variables
VPC_CIDR="10.0.0.0/16"
REGION="ap-southeast-2"
VPC_NAME="BashScriptVPC"
AVAILABILITY_ZONE="ap-southeast-2a"
PUBLIC_SUBNET_1_CIDR="10.0.1.0/24"
PUBLIC_SUBNET_1_NAME="Public-Subnet-1"
PUBLIC_SUBNET_2_CIDR="10.0.2.0/24"
PUBLIC_SUBNET_2_NAME="Public-Subnet-2"
PRIVATE_SUBNET_1_CIDR="10.0.3.0/24"
PRIVATE_SUBNET_1_NAME="Private-Subnet-1"
PRIVATE_SUBNET_2_CIDR="10.0.4.0/24"
PRIVATE_SUBNET_2_NAME="Private-Subnet-2"

# Global Functions

CreateTags() {
    aws ec2 create-tags \
        --resources $1 \
        --tags Key=Name,Value=$2 \
        --region $3

}

ModifyVPCAttribute() {
    aws ec2 modify-vpc-attribute \
        --vpc-id $1 \
        --enable-dns-support \
        --region $2

    aws ec2 modify-vpc-attribute \
        --vpc-id $1 \
        --enable-dns-hostnames \
        --region $2

}

CreateSubnet() {
    aws ec2 create-subnet \
        --vpc-id $1 \
        --cidr-block $2 \
        --availability-zone $3 \
        --region $4 \
        --query 'Subnet.SubnetId' \
        --output text
}

ModifySubnetAttribute() {
    aws ec2 modify-subnet-attribute \
        --subnet-id $1 \
        --map-public-ip-on-launch \
        --region $REGION
}

IfFunctionFails() {
    if [ $? -eq 0 ]; then
        echo "$1"
    else
        echo "$2"
        exit 1
    fi
}

# Display message to the user about script execution
echo "The script is starting..."
sleep 2

# Create a VPC

echo "Creating VPC with CIDR: $VPC_CIDR"
Sleep 2

VPC_ID=$(
    aws ec2 create-vpc \
        --cidr-block $VPC_CIDR \
        --region $REGION \
        --query 'Vpc.VpcId' \
        --output text
)

IfFunctionFails "VPC Created with ID: $VPC_ID" "Error Creating VPC"
sleep 2

#Add Name to VPC

CreateTags $VPC_ID $VPC_NAME $REGION

IfFunctionFails "VPC Name Added Successfully" "Error Adding Name to VPC"
sleep 2

# Enable DNS Support and Hostname Support

ModifyVPCAttribute $VPC_ID $REGION

IfFunctionFails "DNS Support and Hostname Support Enabled" "Error Enabling DNS Support and Hostname Support"
sleep 2

echo "Creating Subnets"

# Create Public Subnet 1 & Name it
PUBLIC_SUBNET_1_ID=$(
    CreateSubnet $VPC_ID $PUBLIC_SUBNET_1_CIDR $AVAILABILITY_ZONE $REGION
)
CreateTags $PUBLIC_SUBNET_1_ID $PUBLIC_SUBNET_1_NAME $REGION

IfFunctionFails "Public Subnet 1 Created with Name: $PUBLIC_SUBNET_1_NAME and ID: $PUBLIC_SUBNET_1_ID" "Error Creating Public 1 Subnet"

# Automatically assign Public IP to Instances in Public Subnet 1

ModifySubnetAttribute $PUBLIC_SUBNET_1_ID
IfFunctionFails "Public IP will be assigned to Instances in Public Subnet 1" "Error Assigning Public IP to Instances in Public Subnet 1"
sleep 2

# Create Public Subnet 2 & Name it
PUBLIC_SUBNET_2_ID=$(
    CreateSubnet $VPC_ID $PUBLIC_SUBNET_2_CIDR $AVAILABILITY_ZONE $REGION
)
CreateTags $PUBLIC_SUBNET_2_ID $PUBLIC_SUBNET_2_NAME $REGION

IfFunctionFails "Public Subnet 2 Created with Name: $PUBLIC_SUBNET_2_NAME and ID: $PUBLIC_SUBNET_2_ID" "Error Creating Public Subnet 2"
sleep 2
# Automatically assign Public IP to Instances in Public Subnet 2

ModifySubnetAttribute $PUBLIC_SUBNET_2_ID

IfFunctionFails "Public IP will be assigned to Instances in Public Subnet 2" "Error Assigning Public IP to Instances in Public Subnet 2"
sleep 2

# Create Private Subnet 1 & Name it
PRIVATE_SUBNET_1_ID=$(
    CreateSubnet $VPC_ID $PRIVATE_SUBNET_1_CIDR $AVAILABILITY_ZONE $REGION
)
CreateTags $PRIVATE_SUBNET_1_ID $PRIVATE_SUBNET_1_NAME $REGION

IfFunctionFails "Private Subnet 1 Created with Name: $PRIVATE_SUBNET_1_NAME and ID: $PRIVATE_SUBNET_1_ID" "Error Creating Private Subnet 1"
sleep 2

# Create Private Subnet 2 & Name it
PRIVATE_SUBNET_2_ID=$(
    CreateSubnet $VPC_ID $PRIVATE_SUBNET_2_CIDR $AVAILABILITY_ZONE $REGION
)
CreateTags $PRIVATE_SUBNET_2_ID $PRIVATE_SUBNET_2_NAME $REGION

IfFunctionFails "Private Subnet 2 Created with Name: $PRIVATE_SUBNET_2_NAME and ID: $PRIVATE_SUBNET_2_ID" "Error Creating Private Subnet 2"
sleep 2
echo "VPC, Subnets, and Tags Created Successfully" && echo "Creating Security Group and Adding Rules"
sleep 2

# Import the SecurityGroup.sh script

source SecurityGroup.sh

# Import the InternetGateway.sh script

source InternetGateway.sh

# Import the RouteTables.sh script

source RouteTables.sh

# Import the KeyPair.sh script

source KeyPair.sh

# Import the EC2.sh script

source EC2.sh
