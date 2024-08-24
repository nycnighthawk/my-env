#!/bin/sh

# Function to display help
show_help() {
    echo "Usage: $0 --pod POD_NAME [--pod POD_NAME] [--namespace NAMESPACE_NAME]"
    echo
    echo "Arguments:"
    echo "  --pod        Name of the pod. This is a required argument."
    echo "  --namespace  Name of the namespace."
    exit 1
}

# Function to parse command line arguments
parse_args() {
    # Initialize variables
    pod_names=""
    namespace_name=""

    # Process command line arguments
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --pod)
                shift
                pod_names="$pod_names $1"
                ;;
            --namespace)
                shift
                namespace_name="$1"
                ;;
            --help|-h)
                show_help
                ;;
            *)
                show_help
                ;;
        esac
        shift
    done

    # Check if --pod argument is provided
    if [ -z "$pod_names" ]; then
        show_help
    fi
}

get_max_length() {
    len1=$1
    len2=$2
    if [ "$len1" -gt "$len2" ]; then
        echo "$len1"
    else
        echo "$len2"
    fi
}

convert_to_csv() {
    # Join all arguments with a newline
    local IFS=$'\n'
    joined_args="$*"

    # Use awk to escape fields containing a comma
    echo "$joined_args" | awk 'BEGIN {OFS=","} {if($0 ~ /,/) $0="\""$0"\""} 1' ORS=',' | sed 's/,$/\n/'
}

print_heading_and_data() {
    # The first argument is the temporary file
    tmpfile=$1

    # Get the total number of lines
    total_lines=$(wc -l < "$tmpfile")

    # Use awk to print the heading and data in a table format
    awk -v total_lines="$total_lines" '
    BEGIN {
        # Read the first line (heading) and last line (max lengths)
        getline heading < "'"$tmpfile"'"
        max_lengths_command="tail -n 1 '"$tmpfile"'"
        max_lengths_command | getline max_lengths

        # Split the heading and max lengths into arrays
        split(heading, headings, ",")
        split(max_lengths, max_lengths_arr, ",")
    }
    {
        # Print the heading
        if (NR == 1) {
            for (i = 1; i <= length(headings); i++) {
                printf "%-*s ", max_lengths_arr[i], headings[i]
            }
            print ""
        }

        # Print the data, skipping the last line
        else if (NR < total_lines) {
            split($0, data, ",")
            for (i = 1; i <= length(data); i++) {
                printf "%-*s ", max_lengths_arr[i], data[i]
            }
            print ""
        }
    }' "$tmpfile"
}

process_containers() {
    pod_detail_file=$1
    tmpfile=$2
    maxContainerNameLength=$3

    # Get the number of containers
    num_containers=$(jq -r '.spec.containers | length' "$pod_detail_file")

    # Loop over the containers
    for i in $(seq 0 $(($num_containers - 1))); do
        # Extract the container name
        containerName=$(jq -r ".spec.containers[$i].name" "$pod_detail_file")

        # Update the maximum length of the container name field
        maxContainerNameLength=$(get_max_length ${#containerName} $maxContainerNameLength)

        # Get the number of port mappings for the current container
        num_ports=$(jq -r ".spec.containers[$i].ports | length" "$pod_detail_file")

        # Loop over the port mappings
        for j in $(seq 0 $(($num_ports - 1))); do
            # Extract the host port, container port, and protocol for each port mapping
            hostPort=$(jq -r ".spec.containers[$i].ports[$j].hostPort" "$pod_detail_file")
            containerPort=$(jq -r ".spec.containers[$i].ports[$j].containerPort" "$pod_detail_file")
            protocol=$(jq -r ".spec.containers[$i].ports[$j].protocol" "$pod_detail_file")

            # Only add the network settings to the array if all the fields are not null
            if [ "$hostPort" != "null" ] && [ "$containerPort" != "null" ] && [ "$protocol" != "null" ]; then
                # Convert container details to CSV and append to the temporary file
                convert_to_csv "$podName" "$nodeName" "$hostIP" "$containerName" "$containerPort" "$hostPort" "$protocol" >> "$tmpfile"
            fi
        done
    done

    # Return the maximum length of the container name
    echo $maxContainerNameLength
}

network_detail() {
    pod_name=$1
    namespace_name=$2
    max_length_file=$3
    pod_detail_file=$4

    # Build the command line string
    cmd="kubectl get pod $pod_name"
    if [ -n "$namespace_name" ]; then
        cmd="$cmd -n $namespace_name"
    fi
    cmd="$cmd -o json"

    # Execute the command and store the output in a variable
    output=$(eval "$cmd")

    # Extract the pod information
    pod_info=$(echo "$output" | jq -r '.metadata.name as $pod_name | .spec.nodeName as $node_name | .status.hostIP as $host_ip | .status.podIP as $pod_ip | .spec.containers[] | .name as $container_name | .ports[] | "\($pod_name) \($node_name) \($host_ip) \($container_name) \($pod_ip) \(.containerPort) \(.protocol) \(.hostPort)"')

    # Append the pod information to the pod detail file
    echo "$pod_info" >> "$pod_detail_file"

    # Compute the new length of each column
    new_length=$(echo "$pod_info" | awk '{for(i=1;i<=NF;i++)printf length($i) " ";print ""}' | head -n 1)

    # Retrieve the max length data
    max_length=$(cat "$max_length_file")

    # Compare the new length with the max length and update the max length if necessary
    updated_max_length=$(awk -v new="$new_length" -v old="$max_length" 'BEGIN{split(new, a); split(old, b); for(i=1;i<=length(a);i++)if(a[i]>b[i])printf a[i] " ";else printf b[i] " ";print ""}')

    # Update the max length file with the updated max length
    echo "$updated_max_length" > "$max_length_file"
}

# Function to print network details
display_details() {
    max_length_file=$1
    pod_detail_file=$2

    # Retrieve the max length data
    max_length=$(cat "$max_length_file")

    # Format the headers based on the max length
    headers="Pod Name,Node Name,Node IP,Container Name,Pod IP,Container Port,Protocol,Host Port"
    echo "$headers" | awk -v max_length="$max_length" 'BEGIN{FS=","; OFS=" "; split(max_length, lengths)} {for(i=1;i<=NF;i++)printf "%-*s ", lengths[i], $i; print ""}'

    # Format and display the details of the pods based on the max length
    awk -v max_length="$max_length" 'BEGIN{FS=" "; OFS=" "; split(max_length, lengths)} {for(i=1;i<=NF;i++)printf "%-*s ", lengths[i], $i; print ""}' "$pod_detail_file"
}

_main() {

    parse_args "$@"
    max_length_file=$(mktemp)
    echo "8 9 7 14 12 13 8" > "$max_length_file"

    # Create a tmp file for the pod details
    pod_detail_file=$(mktemp)

    # Call network_detail function for each pod
    echo "max length file: $max_length_file"
    echo "pod detail file: $pod_detail_file"
    for pod_name in $pod_names; do
        echo "processing pod: $pod_name"
        network_detail "$pod_name" "$namespace_name" "$max_length_file" "$pod_detail_file"
    done

    # Call display_details function
    display_details "$max_length_file" "$pod_detail_file"

    # Remove the tmp files
    cat "$max_length_file"
    cat "$pod_detail_file"
    rm "$max_length_file"
    rm "$pod_detail_file"
}

# Call the main function
_main "$@"
