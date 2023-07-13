#!/bin/bash
# This file selects the correct healthcheck to run based off command line arguments then returns a 0 status if the healthcheck was sucsessful

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        # The URL to check outbound connectivity, default is google
        --healthchecks)
            url="$2"
            shift
            ;;
        # The port to check inbound connectivity, default is to ping all open ports
        --argument)
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

for h in $healthcheck ; then
    if [ $h -eq "file_permissions" ] ; then
        source ./file_permissions.sh
        ret_code=$?  
    elif [ $h -eq "connectivity" ] ; then
        source ./connectivity.sh
        ret_code=$?  
    elif [ $h -eq "misconfigurations" ] ; then
        source ./misconfigurations.sh
        ret_code=$?  
    elif [ $h -eq "resource_exhaustion" ] ; then
        source ./resource_exhaustion.sh
        ret_code=$?  
    elif [ $h -eq "service_availability" ] ; then
        source ./service_availability.sh
        ret_code=$?  
    elif [ $h -eq "vulnerabilities" ] ; then
        source ./vulnerabilities.sh
        ret_code=$?  
    elif [ $h -eq "wireguard" ] ; then
        source ./wireguard.sh
        ret_code=$?  
    fi
    
    if [ ret_code -eq 1 ] ; then
        exit 1
    fi
fi
exit 0