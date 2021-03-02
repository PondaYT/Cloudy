#!/bin/sh
SENSITIVE_DIR="Cloudy/Submodule/CloudySensitives"
TARGET_DIR="Cloudy/Sensitive"

# Check if the sensitive directory exists
if [ ! -d $SENSITIVE_DIR ] 
then
    echo "No senstitive data existing. " 
    exit 0
fi

# Copy sensitive data
cp -rf $SENSITIVE_DIR/* $TARGET_DIR