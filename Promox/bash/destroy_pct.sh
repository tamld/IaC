#!/bin/bash

# List all existing containers
echo "Available containers:"
pct list

# Prompt user for containers to delete
read -p "Enter the CTIDs of the containers you want to destroy (separate by space, e.g., 101 102): " PCTS_TO_DESTROY

# Check if input is empty
if [ -z "$PCTS_TO_DESTROY" ]; then
    echo "Error: No CTIDs provided."
    exit 1
fi

# Confirm before deletion
echo "You have selected the following containers to destroy: $PCTS_TO_DESTROY"
read -p "Are you sure you want to destroy these containers? This action cannot be undone! (yes/YES/y to confirm): " CONFIRM

# Normalize user input to lowercase
CONFIRM=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')

if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "y" ]]; then
    echo "Aborting container destruction."
    exit 1
fi

# Loop through the CTIDs and destroy each container
for CTID in $PCTS_TO_DESTROY; do
    # Check if the container exists
    if ! pct status "$CTID" > /dev/null 2>&1; then
        echo "Error: Container with CTID $CTID does not exist. Skipping."
        continue
    fi

    # Stop the container if it is running
    if pct status "$CTID" | grep -q "status: running"; then
        echo "Stopping container $CTID..."
        pct stop "$CTID"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to stop container $CTID. Skipping."
            continue
        fi
    fi

    # Destroy the container
    echo "Destroying container $CTID..."
    pct destroy "$CTID"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to destroy container $CTID."
    else
        echo "Container $CTID destroyed successfully."
    fi
done

echo "Container destruction process completed."
