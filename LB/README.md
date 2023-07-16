```markdown
# Load Balancing Script using iptables

This script enables load balancing using iptables. It sets up rules to distribute incoming traffic across multiple backend servers based on a Virtual IP address (VIP) and a specific port number.

## Prerequisites

- Linux-based operating system
- Superuser (root) access or sudo privileges

## Usage

1. Clone or download the script from the repository.

2. Make the script executable:
   ```shell
   chmod +x iptables_load_balancing.sh
   ```

3. Run the script with the following command to set up load balancing:
   ```shell
   sudo ./iptables_load_balancing.sh -v <VIP> -p <PORT> -b "<BACKEND1> <BACKEND2> ..."
   ```
   Replace `<VIP>` with the Virtual IP address you want to use, `<PORT>` with the desired port number, and `<BACKEND1> <BACKEND2> ...` with the IP addresses of the backend servers separated by spaces.

   Example:
   ```shell
   sudo ./iptables_load_balancing.sh -v 192.168.1.100 -p 80 -b "192.168.1.10 192.168.1.11" 
   ```

   This will enable load balancing for incoming traffic on the specified VIP and port, distributing it across the provided backend servers.

4. To remove the load balancing rules, run the script with the `--remove` option:
   ```shell
   sudo ./iptables_load_balancing.sh --remove
   ```
   This will remove the load balancing rules and restore the previous iptables configuration.

## Options

The script supports the following options:

- `-h`, `--help`: Displays the help menu with usage instructions.
- `-v`, `--vip <IP>`: Specifies the Virtual IP address (VIP) to be used for load balancing.
- `-p`, `--port <PORT>`: Specifies the port number to be load balanced.
- `-b`, `--backends <IPs>`: Specifies the backend server IP addresses, separated by spaces.

## Rollback

The script automatically creates a backup of the iptables configuration before making any changes. If you need to rollback the load balancing rules, you can run the script with the `--remove` option. It will remove the load balancing rules and restore the previous iptables configuration from the backup.

## Disclaimer

- Use this script at your own risk. Make sure to test it in a controlled environment before deploying it in a production environment.
- The script assumes you have a basic understanding of iptables and networking concepts.
- The script may require modification to fit your specific network environment or requirements.

## License

This project is licensed under the [MIT License](LICENSE).
```

Feel free to modify and customize the README.md file according to your preferences and specific use case.