#!/bin/bash

# Source the utility functions
source ./utils.sh

# Function to create a container
create_container() {
  container_name=$(prompt_input "Enter the name of the container")
  print_processing "Creating container $container_name"
  lxc launch ubuntu:20.04 $container_name
  check_command_success "Creating container $container_name"
}

# Function to create a VM
create_vm() {
  vm_name=$(prompt_input "Enter the name of the VM")
  print_processing "Creating VM $vm_name"
  # VM creation command (assuming you're using LXD with VM support)
  lxc launch images:ubuntu/20.04 $vm_name
  check_command_success "Creating VM $vm_name"
}

# Function to create a storage pool
create_storage_pool() {
  pool_name=$(prompt_input "Enter the name of the storage pool")
  pool_driver=$(prompt_input "Enter the pool driver (e.g., btrfs, zfs, dir)")
  print_processing "Creating storage pool $pool_name with driver $pool_driver"
  lxc storage create $pool_name $pool_driver
  check_command_success "Creating storage pool $pool_name"
}

# Function to create a network
create_network() {
  network_name=$(prompt_input "Enter the name of the network")
  print_processing "Creating network $network_name"
  lxc network create $network_name
  check_command_success "Creating network $network_name"
}

# Function to create a profile
create_profile() {
  profile_name=$(prompt_input "Enter the name of the profile")
  print_processing "Creating profile $profile_name"
  lxc profile create $profile_name
  check_command_success "Creating profile $profile_name"
}

# Function to create an image
create_image() {
  image_name=$(prompt_input "Enter the name of the image")
  print_processing "Creating image $image_name"
  lxc image copy ubuntu:20.04 local:$image_name
  check_command_success "Creating image $image_name"
}

# Menu for creating resources
create_menu() {
  print_menu_header "Create Resource"
  
  echo "1. Create Container"
  echo "2. Create VM"
  echo "3. Create Storage Pool"
  echo "4. Create Network"
  echo "5. Create Profile"
  echo "6. Create Image"
  echo "7. Back to Main Menu"

  echo -n "Enter your choice: "
  read choice
  
  case $choice in
    1)
      create_container
      ;;
    2)
      create_vm
      ;;
    3)
      create_storage_pool
      ;;
    4)
      create_network
      ;;
    5)
      create_profile
      ;;
    6)
      create_image
      ;;
    7)
      return
      ;;
    *)
      print_error "Invalid option. Please try again."
      create_menu
      ;;
  esac
}

# Start the creation menu
create_menu

