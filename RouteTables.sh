#!/bin/bash

# This script will fetch route table ID, create new route table and add routes.

# Variables

MAIN_ROUTE_TABLE_NAME="BashMainRT"
PRIVATE_ROUTE_TABLE_NAME="BashPrivateRT"

# Fetch the Main Route Table ID created during the creation of VPC

MAIN_ROUTE_TABLE_ID=$(
    aws ec2 describe-route-tables \
        --filters Name=vpc-id,Values=$VPC_ID \
        --query 'RouteTables[*].RouteTableId' \
        --region "ap-southeast-2" \
        --output text
)

# Check if the Main Route Table ID was fetched successfully

IfFunctionFails "Main Route Table ID fetched successfully: $MAIN_ROUTE_TABLE_ID on VPC: $VPC_ID" "Error fetching Main Route Table ID"
sleep 2
# Naming the Main Route Table

CreateTags $MAIN_ROUTE_TABLE_ID $MAIN_ROUTE_TABLE_NAME $REGION

# Check if the Main Route Table was named successfully

IfFunctionFails "Main Route Table named successfully: $MAIN_ROUTE_TABLE_NAME" "Error naming Main Route Table"
sleep 2

# Add routes to the Main Route Table

aws ec2 create-route \
    --route-table-id $MAIN_ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $INTERNET_GATEWAY_ID \
    --region "ap-southeast-2" \
    >/dev/null

# Check if the route was added successfully

IfFunctionFails "Route added successfully to Main Route Table: $MAIN_ROUTE_TABLE_NAME" "Error adding route to Main Route Table"
sleep 2
# Assign the Public Subnets to the Main Route Table

for SUBNET_ID in $PUBLIC_SUBNET_1_ID $PUBLIC_SUBNET_2_ID; do
    aws ec2 associate-route-table \
        --subnet-id $SUBNET_ID \
        --route-table-id $MAIN_ROUTE_TABLE_ID \
        --region "ap-southeast-2" \
        --output text \
        >/dev/null

done

# Check if the Public Subnets were assigned to the Main Route Table

IfFunctionFails "Public Subnets assigned successfully to Main Route Table: $MAIN_ROUTE_TABLE_NAME" "Error assigning Public Subnets to Main Route Table"
sleep 2

# Create a Private Route Table

PRIVATE_ROUTE_TABLE_ID=$(
    aws ec2 create-route-table \
        --vpc-id $VPC_ID \
        --query 'RouteTable.RouteTableId' \
        --region "ap-southeast-2" \
        --output text
)

# Check if the Private Route Table was created successfully

IfFunctionFails "Private Route Table created successfully with ID: $PRIVATE_ROUTE_TABLE_ID" "Error creating Private Route Table"
sleep 2

# Name the Private Route Table

CreateTags $PRIVATE_ROUTE_TABLE_ID $PRIVATE_ROUTE_TABLE_NAME $REGION

# Check if the Private Route Table was named successfully

IfFunctionFails "Private Route Table named successfully: $PRIVATE_ROUTE_TABLE_NAME" "Error naming Private Route Table"
sleep 2

# Assign the Private Subnets to the Private Route Table

for SUBNET_ID in $PRIVATE_SUBNET_1_ID $PRIVATE_SUBNET_2_ID; do
    aws ec2 associate-route-table \
        --subnet-id $SUBNET_ID \
        --route-table-id $PRIVATE_ROUTE_TABLE_ID \
        --region "ap-southeast-2" \
        --output text \
        >/dev/null

done

# Check if the Private Subnets were assigned to the Private Route Table

IfFunctionFails "Private Subnets assigned successfully to Private Route Table: $PRIVATE_ROUTE_TABLE_NAME" "Error assigning Private Subnets to Private Route Table"
sleep 2
