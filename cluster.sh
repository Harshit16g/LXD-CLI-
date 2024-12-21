#!/bin/bash

# Source the utility functions
source ./utils.sh

# Function to initialize a cluster
init_cluster() {
  cluster_name=$(prompt_input "Enter the name for the cluster to initialize")
  cluster_address=$(prompt_input "Enter the IP address or hostname of the first node")
  
  print_processing "Initializing LXD cluster '$cluster_name' with first node at $cluster_address"
  
  # Initialize cluster on the first node
  lxd init --auto --cluster --cluster-address $cluster_address
  
  check_command_success "Initializing LXD cluster"
}

# Function to add a node to the cluster
add_node() {
  node_address=$(prompt_input "Enter the IP address or hostname of the node to add")
  print_processing "Adding node $node_address to the cluster"
  
  # Add node to the cluster
  lxd cluster add $node_address
  
  check_command_success "Adding node $node_address to the cluster"
}

# Function to remove a node from the cluster
remove_node() {
  node_name=$(prompt_input "Enter the name of the node to remove from the cluster")
  print_processing "Removing node $node_name from the cluster"
  
  # Remove node from the cluster
  lxd cluster remove $node_name
  
  check_command_success "Removing node $node_name from the cluster"
}

# Function to list all nodes in the cluster
list_cluster_nodes() {
  print_processing "Listing all nodes in the cluster"
  
  # List nodes in the cluster
  lxc cluster list
  
  check_command_success "Listing cluster nodes"
}

# Function to check the cluster status
cluster_status() {
  print_processing "Checking the status of the cluster"
  
  # Show cluster status
  lxd cluster status
  
  check_command_success "Checking cluster status"
}

# Function to configure the cluster
configure_cluster() {
  print_processing "Configuring cluster settings"
  
  # Cluster configuration options (e.g., setting DNS, backend storage)
  dns_server=$(prompt_input "Enter the DNS server for the cluster")
  storage_backend=$(prompt_input "Enter the storage backend (e.g., btrfs, zfs, etc.)")
  
  # Set DNS and storage backend for the cluster
  lxd cluster set dns.server $dns_server
  lxd cluster set storage.backend $storage_backend
  
  check_command_success "Configuring cluster settings"
}

# Menu for cluster operations
cluster_menu() {
  print_menu_header "Cluster Operations"
  
  echo "1. Initialize Cluster"
  echo "2. Add Node to Cluster"
  echo "3. Remove Node from Cluster"
  echo "4. List Cluster Nodes"
  echo "5. Check Cluster Status"
  echo "6. Configure Cluster Settings"
  echo "7. Back to Main Menu"

  echo -n "Enter your choice: "
  read choice
  
  case $choice in
    1)
      init_cluster
      ;;
    2)
      add_node
      ;;
    3)
      remove_node
      ;;
    4)
      list_cluster_nodes
      ;;
    5)
      cluster_status
      ;;
    6)
      configure_cluster
      ;;
    7)
      return
      ;;
    *)
      print_error "Invalid option. Please try again."
      cluster_menu
      ;;
  esac
}

# Start the cluster menu
cluster_menu

