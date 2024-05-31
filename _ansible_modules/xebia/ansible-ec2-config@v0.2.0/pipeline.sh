#!/bin/bash

# Function to print the current timestamp with timezone
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S %Z'
}

# Check if an argument is provided, if not set default path
TARGET_PATH=${1:-/home/ubuntu/}

# Ensure the provided path is an absolute path
if [[ $TARGET_PATH != /* ]]; then
    echo "Please provide an absolute path."
    exit 1
fi

# Create the directory if it doesn't exist
if [ ! -d "$TARGET_PATH" ]; then
    mkdir -p "$TARGET_PATH"
    echo "Directory created at $TARGET_PATH"
else
    echo "Directory already exists at $TARGET_PATH"
fi

# Create the result.txt file with the specified content and timestamp
{
    echo "This file is created by xlr8s."
    echo -e "Current timestamp: $(get_timestamp)\n"
} > "${TARGET_PATH}/result.txt"
echo "result.txt file created with content at $TARGET_PATH"
