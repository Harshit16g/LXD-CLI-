#!/bin/bash

# Source the utility functions
source ./utils.sh

# Function to create a snapshot of a container or VM
create_snapshot() {
  container_name=$(prompt_input "Enter the name of the container or VM to snapshot")
  snapshot_name=$(prompt_input "Enter a name for the snapshot")
  
  print_processing "Creating snapshot '$snapshot_name' for container/VM '$container_name'"
  
  # Create the snapshot
  lxc snapshot $container_name $snapshot_name
  
  check_command_success "Creating snapshot '$snapshot_name' for container/VM '$container_name'"
}

# Function to list all snapshots of a container or VM
list_snapshots() {
  container_name=$(prompt_input "Enter the name of the container or VM to list snapshots for")
  
  print_processing "Listing all snapshots for container/VM '$container_name'"
  
  # List the snapshots for the specified container/VM
  lxc snapshots $container_name
  
  check_command_success "Listing snapshots for container/VM '$container_name'"
}

# Function to restore a snapshot to a container or VM
restore_snapshot() {
  container_name=$(prompt_input "Enter the name of the container or VM to restore the snapshot to")
  snapshot_name=$(prompt_input "Enter the name of the snapshot to restore")
  
  print_processing "Restoring snapshot '$snapshot_name' to container/VM '$container_name'"
  
  # Restore the snapshot to the container/VM
  lxc restore $container_name $snapshot_name
  
  check_command_success "Restoring snapshot '$snapshot_name' to container/VM '$container_name'"
}

# Function to delete a snapshot of a container or VM
delete_snapshot() {
  container_name=$(prompt_input "Enter the name of the container or VM to delete the snapshot from")
  snapshot_name=$(prompt_input "Enter the name of the snapshot to delete")
  
  print_processing "Deleting snapshot '$snapshot_name' from container/VM '$container_name'"
  
  # Delete the snapshot
  lxc delete $container_name/$snapshot_name
  
  check_command_success "Deleting snapshot '$snapshot_name' from container/VM '$container_name'"
}

# Function to manage snapshots (menu)
snapshot_menu() {
  print_menu_header "Snapshot Operations"
  
  echo "1. Create Snapshot"
  echo "2. List Snapshots"
  echo "3. Restore Snapshot"
  echo "4. Delete Snapshot"
  echo "5. Back to Main Menu"

  echo -n "Enter your choice: "
  read choice
  
  case $choice in
    1)
      create_snapshot
      ;;
    2)
      list_snapshots
      ;;
    3)
      restore_snapshot
      ;;
    4)
      delete_snapshot
      ;;
    5)
      return
      ;;
    *)
      print_error "Invalid option. Please try again."
      snapshot_menu
      ;;
  esac
}

# Start the snapshot menu
snapshot_menu

