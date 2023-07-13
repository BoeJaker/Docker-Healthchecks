#!/bin/sh
# This script performs the health check logic for inbound and outbound connectivity.
# It pings the specified URL

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        # The URL to check outbound connectivity, default is google
        --url)
            url="$2"
            shift
            ;;
        # The port to check inbound connectivity, default is to ping all open ports
        --port)
            port="$2"
            shift
            ;;
        # Unknown option
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
    shift
done

# Check external connectivity by sending an HTTP GET request
[ ! -z "$url" ] && { url="www.google.com" }
[ curl --head --silent --fail "$url" > /dev/null ] || exit 1

# If port supplied check that port for inbound connectivity
if [ ! -z "$container_port" ] ; then
  # Check if the container's port is accessible
  if nc -z -w5 0.0.0.0 "$container_port"; then
    exit 0  # Container is reachable from the outside
  else
    exit 1  # Container is not reachable from the outside
  fi
# If no port is supplied check all ports for inbound connectivity
else
  if \
    lsof -i -P -n | \
    grep LISTEN | \
    awk '{print $9}' | \
    sed 's/\*/0\.0\.0\.0/g' | \
    sed '/\[.*\].*/d' | \
    awk '{split($0,a,":"); print a[1], a[2]}' | \
    xargs -n2 -P0 nc -vz ; then

    exit 0  # Container is reachable from the outside
  else
    exit 1  # Container is not reachable from the outside
  fi
fi

"""
    lsof -i -P -n | \             # Lists all ports
    grep LISTEN | \               # Filters for listening ports
    awk '{print $9}' | \          # Returns addresses only
    sed 's/\*/0\.0\.0\.0/g' | \   # Replace *'s with localhost
    sed '/\[.*\].*/d' | \         # Filter lines that are not CIDR notated
    # Split the address at the port delimeter ':'
    awk '{split($0,a,":"); print a[1], a[2]}' | \
    xargs -n2 -P0 nc -vz          # Supply the arguments in ip/port pairs to nc
"""