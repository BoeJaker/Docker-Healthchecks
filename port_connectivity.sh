#!/bin/sh
# This script performs the health check logic for container's accessability

# Specify the container's port to check via arguments/parameters
container_port="$1"

# If port supplied check that port
if [ ! -z "$container_port" ] ; then
  # Check if the container's port is accessible
  if nc -z -w5 0.0.0.0 "$container_port"; then
    exit 0  # Container is reachable from the outside
  else
    exit 1  # Container is not reachable from the outside
  fi
# If no port is supplied check all ports reporting as up  
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