#!/bin/bash

# Include utilities
source ./utils.sh

# Function to configure a container
configure_container() {
  print_processing "Listing all containers..."
  containers=$(sudo lxc list -c n --format=csv)

  if [ -z "$containers" ]; then
    print_error "No containers found. Exiting configuration."
    return
  fi

  # Display available containers
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"  # Blue line
  echo -e "\033[1;33m***[Available Containers]***:\033[0m"  # Bold yellow text for header

  # Convert containers list into numbered options
  containers_array=($containers)
  for i in "${!containers_array[@]}"; do
    echo "$((i + 1)). ${containers_array[$i]}"
  done
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"  # Blue line

  # Ask user to select a container by number
  echo -n "Enter the number of the container to configure: "
  read container_choice

  # Validate input to ensure it's a valid number
  if ! [[ "$container_choice" =~ ^[0-9]+$ ]] || [ "$container_choice" -lt 1 ] || [ "$container_choice" -gt "${#containers_array[@]}" ]; then
    print_error "Invalid selection. Please select a valid number from the list."
    return
  fi

  container_name="${containers_array[$((container_choice - 1))]}"

  # Menu for configuring the selected container
  echo "Select resource to configure for container $container_name:"
  echo "1. Set Resource Limits (CPU, Memory)"
  echo "2. Add Device to Container"
  echo "3. Set Networking for Container"
  echo "4. Set Storage for Container"
  echo -n "Enter your choice: "
  read config_choice

  case $config_choice in
    1)
      set_container_limits $container_name
      ;;
    2)
      add_device_to_container $container_name
      ;;
    3)
      configure_networking $container_name
      ;;
    4)
      configure_storage $container_name
      ;;
    *)
      print_error "Invalid choice. Returning to main menu."
      configure_menu
      ;;
  esac
}

# Function to configure a storage pool
configure_storage_pool() {
  print_processing "Fetching storage pool configurations..."
  
  # List available storage pools
  storage_pools=$(sudo lxc storage list --format=csv)

  if [ -z "$storage_pools" ]; then
    print_error "No storage pools found."
    return
  fi

  # Display available storage pools
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"
  echo -e "\033[1;33m***[Available Storage Pools]***:\033[0m"
  echo "$storage_pools"
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"

  # Ask for selection of storage pool
  echo -n "Enter the name of the storage pool to configure: "
  read pool_name

  # Fetch current configuration for the selected pool
  print_processing "Fetching current storage pool details for $pool_name..."
  sudo lxc storage show $pool_name

  # Prompt user for new storage configurations
  echo "Enter new storage pool size (e.g., 10GB): "
  read storage_size

  # Update storage pool with the new size
  sudo lxc storage volume set $pool_name size=$storage_size
  print_success "Storage pool $pool_name updated with size $storage_size."
}

# Function to configure resource limits (CPU, Memory) for a container
set_container_limits() {
  container_name=$1
  print_processing "Fetching current resource limits for container $container_name..."

  # Fetch and display current resource limits
  current_cpu=$(sudo lxc config show $container_name | grep 'limits.cpu' | awk '{print $2}')
  current_memory=$(sudo lxc config show $container_name | grep 'limits.memory' | awk '{print $2}')
  
  echo -e "\033[1;32mCurrent Resource Limits for container $container_name:\033[0m"
  echo "CPU Limit: $current_cpu"
  echo "Memory Limit: $current_memory"
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"

  # Ask user for new limits
  echo "Enter new CPU limit (current: $current_cpu, e.g., 2 for 2 CPUs): "
  read cpu_limit
  echo "Enter new memory limit (current: $current_memory, e.g., 4GB): "
  read memory_limit

  # Set new CPU and Memory limits
  sudo lxc config set $container_name limits.cpu $cpu_limit
  sudo lxc config set $container_name limits.memory $memory_limit
  
  print_success "Resource limits updated for container $container_name."
}

# Function to add a device to a container
add_device_to_container() {
  container_name=$1
  print_processing "Fetching current device configuration for container $container_name..."

  # Fetch current devices
  current_devices=$(sudo lxc config device list $container_name)
  
  echo -e "\033[1;32mCurrent Devices for container $container_name:\033[0m"
  echo "$current_devices"
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"

  # Ask user for new device details
  echo "Enter device name to add (e.g., /dev/sda): "
  read device_name
  echo "Enter the type of device (e.g., disk, network): "
  read device_type
  
  # Add the device to the container
  sudo lxc config device add $container_name $device_name $device_type
  print_success "Device $device_name added to container $container_name."
}

# Function to configure networking for a container
configure_networking() {
  container_name=$1
  print_processing "Fetching current networking configuration for container $container_name..."

  # Fetch current network settings
  current_network=$(sudo lxc network list)
  current_ip=$(sudo lxc exec $container_name -- ip addr show eth0 | grep 'inet' | awk '{print $2}')

  echo -e "\033[1;32mCurrent Networking for container $container_name:\033[0m"
  echo "Network Interfaces: $current_network"
  echo "Assigned IP (eth0): $current_ip"
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"

  # Ask user for new network details
  echo "Enter new IP address to assign to eth0 (current: $current_ip, e.g., 192.168.1.100): "
  read ip_address

  # Attach network to the container and assign new IP
  sudo lxc exec $container_name -- ip addr add $ip_address/24 dev eth0
  print_success "Networking updated for container $container_name with IP $ip_address."
}

# Function to configure storage for a container
configure_storage() {
  container_name=$1
  print_processing "Fetching current storage configuration for container $container_name..."

  # Fetch current storage settings
  current_storage=$(sudo lxc storage volume list)
  
  echo -e "\033[1;32mCurrent Storage for container $container_name:\033[0m"
  echo "$current_storage"
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"

  # Ask user for new storage details
  echo "Enter new storage pool name (e.g., default): "
  read storage_pool_name
  echo "Enter new size of the storage (e.g., 10GB): "
  read storage_size
  
  # Create storage volume for the container
  sudo lxc storage volume create $storage_pool_name $container_name size=$storage_size
  print_success "Storage updated for container $container_name with size $storage_size."
}

# Function to configure VM
# Function to configure a VM
configure_vm() {
  print_processing "Fetching available VMs..."

  # List available VMs (similar to how containers are listed)
  vms=$(sudo lxc list -c n --format=csv --vm)

  if [ -z "$vms" ]; then
    print_error "No virtual machines found."
    return
  fi

  # Display available VMs
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"
  echo -e "\033[1;33m***[Available VMs]***:\033[0m"  # Bold yellow text for header

  # Convert VMs list into numbered options
  vms_array=($vms)
  for i in "${!vms_array[@]}"; do
    echo "$((i + 1)). ${vms_array[$i]}"
  done
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"  # Blue line

  # Ask for selection of a VM
  echo -n "Enter the number of the VM to configure: "
  read vm_choice

  # Validate input to ensure it's a valid number
  if ! [[ "$vm_choice" =~ ^[0-9]+$ ]] || [ "$vm_choice" -lt 1 ] || [ "$vm_choice" -gt "${#vms_array[@]}" ]; then
    print_error "Invalid selection. Please select a valid number from the list."
    return
  fi

  vm_name="${vms_array[$((vm_choice - 1))]}"

  # Menu for configuring the selected VM
  echo "Select resource to configure for VM $vm_name:"
  echo "1. Set Resource Limits (CPU, Memory)"
  echo "2. Set Networking for VM"
  echo "3. Set Storage for VM"
  echo -n "Enter your choice: "
  read vm_config_choice

  case $vm_config_choice in
    1)
      set_vm_limits $vm_name
      ;;
    2)
      configure_vm_networking $vm_name
      ;;
    3)
      configure_vm_storage $vm_name
      ;;
    *)
      print_error "Invalid choice. Returning to main menu."
      configure_menu
      ;;
  esac
}

# Function to set resource limits (CPU, Memory) for VM
set_vm_limits() {
  vm_name=$1
  print_processing "Fetching current resource limits for VM $vm_name..."

  # Fetch and display current resource limits
  current_cpu=$(sudo lxc config show $vm_name | grep 'limits.cpu' | awk '{print $2}')
  current_memory=$(sudo lxc config show $vm_name | grep 'limits.memory' | awk '{print $2}')
  
  echo -e "\033[1;32mCurrent Resource Limits for VM $vm_name:\033[0m"
  echo "CPU Limit: $current_cpu"
  echo "Memory Limit: $current_memory"
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"

  # Ask user for new limits
  echo "Enter new CPU limit (current: $current_cpu, e.g., 2 for 2 CPUs): "
  read cpu_limit
  echo "Enter new memory limit (current: $current_memory, e.g., 4GB): "
  read memory_limit

  # Set new CPU and Memory limits
  sudo lxc config set $vm_name limits.cpu $cpu_limit
  sudo lxc config set $vm_name limits.memory $memory_limit
  
  print_success "Resource limits updated for VM $vm_name."
}

# Function to configure networking for a VM
configure_vm_networking() {
  vm_name=$1
  print_processing "Fetching current networking configuration for VM $vm_name..."

  # Fetch current network settings for the VM
  current_network=$(sudo lxc network list)
  current_ip=$(sudo lxc exec $vm_name -- ip addr show eth0 | grep 'inet' | awk '{print $2}')

  echo -e "\033[1;32mCurrent Networking for VM $vm_name:\033[0m"
  echo "Network Interfaces: $current_network"
  echo "Assigned IP (eth0): $current_ip"
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"

  # Ask user for new network details
  echo "Enter new IP address to assign to eth0 (current: $current_ip, e.g., 192.168.1.100): "
  read ip_address

  # Attach network to the VM and assign new IP
  sudo lxc exec $vm_name -- ip addr add $ip_address/24 dev eth0
  print_success "Networking updated for VM $vm_name with IP $ip_address."
}

# Function to configure storage for a VM
configure_vm_storage() {
  vm_name=$1
  print_processing "Fetching current storage configuration for VM $vm_name..."

  # Fetch current storage settings for the VM
  current_storage=$(sudo lxc storage volume list)

  echo -e "\033[1;32mCurrent Storage for VM $vm_name:\033[0m"
  echo "$current_storage"
  echo -e "\033[1;36m---------------------------------------------------------\033[0m"

  # Ask user for new storage details
  echo "Enter new storage pool name (e.g., default): "
  read storage_pool_name
  echo "Enter new size of the storage (e.g., 10GB): "
  read storage_size
  
  # Create storage volume for the VM
  sudo lxc storage volume create $storage_pool_name $vm_name size=$storage_size
  print_success "Storage updated for VM $vm_name with size $storage_size."
}


# Function to configure network settings
configure_network() {
  container_name=$1

  # Show networking options
  echo "[NETWORK CONFIGURATION]"
  echo "1. Set static IP address for the container"
  echo "2. Configure Network Bridge"
  echo "3. Configure NAT (Port Forwarding)"
  echo "4. Set Firewall rules (iptables)"
  echo "5. Exit Network Configuration"

  read -p "Enter your choice (1-5): " network_choice

  case $network_choice in
    1)
      # Set static IP for the container
      echo "Enter the static IP address for $container_name (e.g., 192.168.1.100/24): "
      read static_ip
      # Apply static IP address using lxc network set
      sudo lxc network set $container_name ipv4.address $static_ip
      sudo lxc network set $container_name ipv4.gateway 192.168.1.1  # Gateway example
      print_success "Static IP $static_ip set for $container_name."
      ;;
    2)
      # Configure a network bridge
      echo "Enter the bridge name (e.g., br0): "
      read bridge_name
      # Create and attach the bridge to the container
      sudo lxc network create $bridge_name ipv4.address=none ipv6.address=none
      sudo lxc network attach $bridge_name $container_name eth0
      print_success "Bridge $bridge_name is now attached to $container_name."
      ;;
    3)
      # Configure NAT (Port Forwarding) for the container
      echo "Enter the external port to forward (e.g., 8080): "
      read external_port
      echo "Enter the internal port on the container (e.g., 80 for HTTP): "
      read internal_port
      # Apply NAT rules for port forwarding using iptables
      sudo lxc exec $container_name -- iptables -t nat -A PREROUTING -p tcp --dport $external_port -j DNAT --to-destination 127.0.0.1:$internal_port
      sudo lxc exec $container_name -- iptables -A FORWARD -p tcp -d 127.0.0.1 --dport $internal_port -j ACCEPT
      print_success "Port forwarding set up: External port $external_port -> Internal port $internal_port."
      ;;
    4)
      # Set Firewall rules using iptables for the container
      echo "Select a firewall rule to apply for $container_name:"
      echo "1. Allow traffic on a specific port (e.g., HTTP, HTTPS)"
      echo "2. Block traffic on a specific port"
      echo "3. Allow traffic from a specific IP"
      echo "4. Block traffic from a specific IP"
      echo "5. Set up rate limiting"
      echo "6. Apply custom iptables rule"
      echo "7. Exit Firewall Configuration"

      read -p "Enter your choice (1-7): " firewall_choice

      case $firewall_choice in
        1)
          # Allow traffic on a specific port
          echo "Enter the port number to allow (e.g., 80 for HTTP, 443 for HTTPS): "
          read port
          sudo lxc exec $container_name -- iptables -A INPUT -p tcp --dport $port -j ACCEPT
          print_success "Port $port is now allowed on $container_name."
          ;;
        2)
          # Block traffic on a specific port
          echo "Enter the port number to block: "
          read block_port
          sudo lxc exec $container_name -- iptables -A INPUT -p tcp --dport $block_port -j REJECT
          print_success "Port $block_port is now blocked on $container_name."
          ;;
        3)
          # Allow traffic from a specific IP
          echo "Enter the IP address to allow: "
          read ip_address
          sudo lxc exec $container_name -- iptables -A INPUT -p tcp -s $ip_address -j ACCEPT
          print_success "Traffic from $ip_address is now allowed on $container_name."
          ;;
        4)
          # Block traffic from a specific IP
          echo "Enter the IP address to block: "
          read block_ip
          sudo lxc exec $container_name -- iptables -A INPUT -p tcp -s $block_ip -j REJECT
          print_success "Traffic from $block_ip is now blocked on $container_name."
          ;;
        5)
          # Set up rate limiting
          echo "Enter the port to apply rate limiting (e.g., 80 for HTTP): "
          read rate_limit_port
          echo "Enter the rate limit (e.g., 100/minute): "
          read rate_limit
          sudo lxc exec $container_name -- iptables -A INPUT -p tcp --dport $rate_limit_port -m limit --limit $rate_limit -j ACCEPT
          print_success "Rate limit applied to port $rate_limit_port: $rate_limit."
          ;;
        6)
          # Apply custom iptables rule
          echo "Enter the custom iptables rule (e.g., '-A INPUT -p tcp --dport 8080 -j ACCEPT'): "
          read custom_rule
          sudo lxc exec $container_name -- iptables $custom_rule
          print_success "Custom iptables rule applied: $custom_rule"
          ;;
        7)
          # Exit firewall configuration
          print_info "Exiting firewall configuration."
          return
          ;;
        *)
          print_error "Invalid choice. Please select a valid option."
          ;;
      esac

      # Ask if the user wants to configure another firewall rule
      echo "Do you want to configure another firewall rule? (y/n): "
      read configure_again
      if [[ "$configure_again" == "y" || "$configure_again" == "Y" ]]; then
        configure_network $container_name
      else
        print_info "Exiting firewall configuration."
      fi
      ;;
    5)
      # Exit network configuration
      print_info "Exiting network configuration."
      return
      ;;
    *)
      print_error "Invalid choice. Please select a valid option."
      ;;
  esac

  # Ask if the user wants to configure another network setting
  echo "Do you want to configure another network setting? (y/n): "
  read configure_again
  if [[ "$configure_again" == "y" || "$configure_again" == "Y" ]]; then
    configure_network $container_name
  else
    print_info "Exiting network configuration."
  fi
}

# Function to configure a profile
configure_profile() {
  print_processing "Fetching profile configurations..."

  echo "[PROFILE CONFIGURATION]"
  echo "1. Configure User Limits (e.g., Max Processes, Max Memory)"
  echo "2. Configure Environment Variables"
  echo "3. Configure SSH Keys"
  echo "4. Configure User Permissions"
  echo "5. Back to Main Menu"

  read -p "Enter your choice (1-5): " profile_choice

  case $profile_choice in
    1)
      # Configure user limits (e.g., max processes, max memory)
      echo "Enter the username to configure limits for: "
      read username

      echo "Enter the maximum number of processes for $username: "
      read max_processes
      echo "Enter the maximum memory limit for $username (in KB): "
      read max_memory

      # Apply limits (e.g., using /etc/security/limits.conf or /etc/systemd/system/user.service for systemd services)
      echo "$username soft nproc $max_processes" | sudo tee -a /etc/security/limits.conf
      echo "$username hard nproc $max_processes" | sudo tee -a /etc/security/limits.conf
      echo "$username soft memlock $max_memory" | sudo tee -a /etc/security/limits.conf
      echo "$username hard memlock $max_memory" | sudo tee -a /etc/security/limits.conf

      print_success "User limits configured for $username: Max processes = $max_processes, Max memory = $max_memory KB."
      ;;
    2)
      # Configure environment variables
      echo "Enter the environment variable name (e.g., PATH, JAVA_HOME): "
      read env_var_name
      echo "Enter the value for $env_var_name: "
      read env_var_value

      # Apply environment variables globally (e.g., /etc/environment) or per user
      echo "$env_var_name=$env_var_value" | sudo tee -a /etc/environment

      print_success "Environment variable $env_var_name set to $env_var_value."
      ;;
    3)
      # Configure SSH Keys
      echo "Enter the username for SSH key configuration: "
      read ssh_username

      echo "Enter the path to the public SSH key (e.g., /home/$USER/.ssh/id_rsa.pub): "
      read ssh_key_path

      # Ensure the user’s SSH directory exists
      sudo mkdir -p /home/$ssh_username/.ssh
      sudo chmod 700 /home/$ssh_username/.ssh

      # Append the public key to the authorized_keys file
      sudo cat $ssh_key_path | sudo tee -a /home/$ssh_username/.ssh/authorized_keys
      sudo chmod 600 /home/$ssh_username/.ssh/authorized_keys

      print_success "SSH key has been added for $ssh_username."
      ;;
    4)
      # Configure user permissions
      echo "Enter the username to configure permissions for: "
      read username

      echo "Enter the group to assign the user to (e.g., sudo, docker): "
      read group_name

      # Add user to the specified group
      sudo usermod -aG $group_name $username

      print_success "User $username has been added to group $group_name."
      ;;
    5)
      # Exit profile configuration
      print_info "Exiting profile configuration."
      return
      ;;
    *)
      print_error "Invalid choice. Please select a valid option."
      ;;
  esac

  # Ask if the user wants to configure another profile setting
  echo "Do you want to configure another profile setting? (y/n): "
  read configure_again
  if [[ "$configure_again" == "y" || "$configure_again" == "Y" ]]; then
    configure_profile
  else
    print_info "Exiting profile configuration."
  fi
}


# Function to display menu for configuring containers
configure_menu() {
  # Clear terminal screen (Optional)
  clear
  echo "--------------------------------------"
  echo "[CONFIGURATION MENU]"
  echo "1. Configure Container"
  echo "2. Configure VM"
  echo "3. Configure Storage Pool"
  echo "4. Configure Network"
  echo "5. Configure Profile"
  echo "6. Back to Main Menu"
  echo -n "Enter your choice: "
  read choice

  case $choice in
    1)
      configure_container
      ;;
    2)
      configure_vm
      ;;
    3)
      configure_storage_pool
      ;;
    4)
      configure_network
      ;;
    5)
      configure_profile
      ;;
    6)
         # Return to main menu by calling main.sh again
      print_info "Returning to Main Menu..."
      sudo ./main.sh
      return
      ;;
    *)
      print_error "Invalid choice. Please select a valid option."
      ;;
  esac

}

# Start Configuration Menu
configure_menu

