#!/bin/sh

# Function to print usage
usage() {
    echo "Usage: $0 POD_NAME [--network]"
    exit 1
}

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    usage
fi

POD_NAME=$1
shift

# Function to print network details
network_details() {
    echo "Fetching network details for pod $POD_NAME..."
    echo "HOST_IP, HOST_PORT, CONTAINER_IP, CONTAINER_PORT, PROTOCOL"

    # Get the pod details
    POD_DETAILS=$(kubectl get pod $POD_NAME -o json)

    # Extract the details
    HOST_IP=$(echo $POD_DETAILS | jq -r '.status.hostIP')
    CONTAINER_IP=$(echo $POD_DETAILS | jq -r '.status.podIP')
    CONTAINER_PORT=$(echo $POD_DETAILS | jq -r '.spec.containers[0].ports[0].containerPort')
    HOST_PORT=$(echo $POD_DETAILS | jq -r '.spec.containers[0].ports[0].hostPort')
    PROTOCOL=$(echo $POD_DETAILS | jq -r '.spec.containers[0].ports[0].protocol')

    # Print the details
    echo "$HOST_IP, $HOST_PORT, $CONTAINER_IP, $CONTAINER_PORT, $PROTOCOL"
}

# Process options
while [ "$1" != "" ]; do
    case $1 in
        --network )    network_details
                       ;;
        * )            usage
    esac
    shift
done
