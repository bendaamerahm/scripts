# Default configuration parameters
VIP=""
PORT=""
BACKENDS=()

# Help menu
function display_help {
  echo "Load Balancing Script using iptables"
  echo "------------------------------------"
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  -h, --help             Display this help menu"
  echo "  -v, --vip <IP>         Specify the Virtual IP address (VIP)"
  echo "  -p, --port <PORT>      Specify the port number"
  echo "  -b, --backends <IPs>   Specify the backend server IP addresses, separated by spaces"
  echo
}

# Enable IP forwarding
function enable_ip_forwarding {
  echo "Enabling IP forwarding..."
  sudo sysctl -w net.ipv4.ip_forward=1
  echo "IP forwarding enabled."
}

# Set up load balancing rules
function set_up_load_balancing {
  # Delete any existing rules and chains
  sudo iptables -t nat -F
  sudo iptables -t nat -X
  sudo iptables -t mangle -F
  sudo iptables -t mangle -X

  # Create a backup of the existing iptables configuration
  echo "Backing up the iptables configuration..."
  sudo iptables-save > iptables_backup_$(date +"%Y%m%d%H%M%S").rules
  echo "iptables configuration backup created."

  # Create a new chain for load balancing
  sudo iptables -t nat -N LB_CHAIN

  # Assign the VIP to the load balancing chain
  sudo iptables -t nat -A LB_CHAIN -d $VIP -j RETURN

  # Distribute traffic to backend servers
  for backend in "${BACKENDS[@]}"; do
    sudo iptables -t nat -A LB_CHAIN -p tcp -m tcp -d $backend --dport $PORT -j DNAT --to-destination $backend:$PORT
  done

  # Enable SNAT for outgoing traffic
  sudo iptables -t nat -A POSTROUTING -p tcp --dport $PORT -j MASQUERADE

  # Redirect incoming traffic to the load balancing chain
  sudo iptables -t nat -A PREROUTING -p tcp --dport $PORT -j DNAT --to-destination $VIP:$PORT
  sudo iptables -t nat -A PREROUTING -p tcp -m tcp -d $VIP --dport $PORT -j REDIRECT --to-ports $PORT

  echo "Load balancing rules using iptables set up."
  echo "To remove load balancing, run the script with the '--remove' option."
}

# Remove load balancing rules and restore from backup
function remove_load_balancing {
  # Remove the load balancing rules
  sudo iptables -t nat -F LB_CHAIN
  sudo iptables -t nat -X LB_CHAIN
  sudo iptables -t nat -D POSTROUTING -p tcp --dport $PORT -j MASQUERADE
  sudo iptables -t nat -D PREROUTING -p tcp --dport $PORT -j DNAT --to-destination $VIP:$PORT
  sudo iptables -t nat -D PREROUTING -p tcp -m tcp -d $VIP --dport $PORT -j REDIRECT --to-ports $PORT

  echo "Load balancing rules removed."

  # Restore iptables configuration from backup
  if [ -f "iptables_backup_*" ]; then
    echo "Restoring iptables configuration from backup..."
    sudo iptables-restore < $(ls -t iptables_backup_* | head -1)
    echo "iptables configuration restored from backup."
  else
    echo "No iptables backup found."
  fi
}

# Process command line arguments
function process_args {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        display_help
        exit 0
        ;;
      -v|--vip)
        VIP="$2"
        shift 2
        ;;
      -p|--port)
        PORT="$2"
        shift 2
        ;;
      -b|--backends)
        BACKENDS=($2)
        shift 2
        ;;
      *)
        echo "Invalid option: $1"
        display_help
        exit 1
        ;;
    esac
  done
}

# Main script logic
function main {
  # Process command line arguments
  process_args "$@"

  # Enable IP forwarding
  enable_ip_forwarding

  # Set up load balancing
  set_up_load_balancing

  # Prompt for rollback option
  read -p "Do you want to remove load balancing rules? [y/N]: " rollback_choice
  if [[ $rollback_choice == "y" || $rollback_choice == "Y" ]]; then
    remove_load_balancing
  fi
}

# Execute the script
main "$@"
