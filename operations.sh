#!/bin/bash

# Source the utility functions
source ./utils.sh

# Function to start a container or VM
start_container() {
  container_name=$(prompt_input "Enter the name of the container or VM to start")
  
  print_processing "Starting container/VM '$container_name'"
  
  # Start the container/VM
  lxc start $container_name
  
  check_command_success "Starting container/VM '$container_name'"
}

# Function to stop a container or VM
stop_container() {
  container_name=$(prompt_input "Enter the name of the container or VM to stop")
  
  print_processing "Stopping container/VM '$container_name'"
  
  # Stop the container/VM
  lxc stop $container_name
  
  check_command_success "Stopping container/VM '$container_name'"
}

# Function to restart a container or VM
restart_container() {
  container_name=$(prompt_input "Enter the name of the container or VM to restart")
  
  print_processing "Restarting container/VM '$container_name'"
  
  # Restart the container/VM
  lxc restart $container_name
  
  check_command_success "Restarting container/VM '$container_name'"
}

# Function to get the status of a container or VM
status_container() {
  container_name=$(prompt_input "Enter the name of the container or VM to check its status")
  
  print_processing "Checking status of container/VM '$container_name'"
  
  # Get the status of the container/VM
  lxc info $container_name | grep "Status"
  
  check_command_success "Checking status of container/VM '$container_name'"
}

# Function to manage container/VM operations (menu)
operations_menu() {
  print_menu_header "Container/VM Operations"
  
  echo "1. Start Container/VM"
  echo "2. Stop Container/VM"
  echo "3. Restart Container/VM"
  echo "4. Check Container/VM Status"
  echo "5. Back to Main Menu"

  echo -n "Enter your choice: "
  read choice
  
  case $choice in
    1)
      start_container
      ;;
    2)
      stop_container
      ;;
    3)
      restart_container
      ;;
    4)
      status_container
      ;;
    5)
      return
      ;;
    *)
      print_error "Invalid option. Please try again."
      operations_menu
      ;;
  esac
}

# Start the operations menu
operations_menu

