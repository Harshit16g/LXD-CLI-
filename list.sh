#!/bin/bash

# Source the utility functions
source ./utils.sh

# Function to list all containers
list_containers() {
  print_processing "Listing all containers"
  lxc list
  check_command_success "Listing all containers"
}

# Function to list all VMs
list_vms() {
  print_processing "Listing all VMs"
  lxc list --vm
  check_command_success "Listing all VMs"
}

# Function to list all storage pools
list_storage_pools() {
  print_processing "Listing all storage pools"
  lxc storage list
  check_command_success "Listing all storage pools"
}

# Function to list all networks
list_networks() {
  print_processing "Listing all networks"
  lxc network list
  check_command_success "Listing all networks"
}

# Function to list all profiles
list_profiles() {
  print_processing "Listing all profiles"
  lxc profile list
  check_command_success "Listing all profiles"
}

# Function to list all images
list_images() {
  print_processing "Listing all images"
  lxc image list
  check_command_success "Listing all images"
}

# Function to list all containers, VMs, and other resources
list_all_resources() {
  print_processing "Listing all resources"
  echo "Containers:"
  lxc list
  echo "VMs:"
  lxc list --vm
  echo "Storage Pools:"
  lxc storage list
  echo "Networks:"
  lxc network list
  echo "Profiles:"
  lxc profile list
  echo "Images:"
  lxc image list
}

# Menu for listing resources
list_menu() {
  print_menu_header "List Resource"
  
  echo "1. List Containers"
  echo "2. List VMs"
  echo "3. List Storage Pools"
  echo "4. List Networks"
  echo "5. List Profiles"
  echo "6. List Images"
  echo "7. List All Resources"
  echo "8. Back to Main Menu"

  echo -n "Enter your choice: "
  read choice
  
  case $choice in
    1)
      list_containers
      ;;
    2)
      list_vms
      ;;
    3)
      list_storage_pools
      ;;
    4)
      list_networks
      ;;
    5)
      list_profiles
      ;;
    6)
      list_images
      ;;
    7)
      list_all_resources
      ;;
    8)
      return
      ;;
    *)
      print_error "Invalid option. Please try again."
      list_menu
      ;;
  esac
}

# Start the list menu
list_menu

