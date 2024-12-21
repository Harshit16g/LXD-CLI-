#!/bin/bash

# Source the utility functions
source ./utils.sh

# Function to delete a container
delete_container() {
  container_name=$(prompt_input "Enter the name of the container to delete")
  print_processing "Deleting container $container_name"
  lxc delete $container_name --force
  check_command_success "Deleting container $container_name"
}

# Function to delete a VM
delete_vm() {
  vm_name=$(prompt_input "Enter the name of the VM to delete")
  print_processing "Deleting VM $vm_name"
  lxc delete $vm_name --force
  check_command_success "Deleting VM $vm_name"
}

# Function to delete a storage pool
delete_storage_pool() {
  pool_name=$(prompt_input "Enter the name of the storage pool to delete")
  print_processing "Deleting storage pool $pool_name"
  lxc storage delete $pool_name
  check_command_success "Deleting storage pool $pool_name"
}

# Function to delete a network
delete_network() {
  network_name=$(prompt_input "Enter the name of the network to delete")
  print_processing "Deleting network $network_name"
  lxc network delete $network_name
  check_command_success "Deleting network $network_name"
}

# Function to delete a profile
delete_profile() {
  profile_name=$(prompt_input "Enter the name of the profile to delete")
  print_processing "Deleting profile $profile_name"
  lxc profile delete $profile_name
  check_command_success "Deleting profile $profile_name"
}

# Function to delete an image
delete_image() {
  image_name=$(prompt_input "Enter the name of the image to delete")
  print_processing "Deleting image $image_name"
  lxc image delete $image_name
  check_command_success "Deleting image $image_name"
}

# Menu for deleting resources
delete_menu() {
  print_menu_header "Delete Resource"
  
  echo "1. Delete Container"
  echo "2. Delete VM"
  echo "3. Delete Storage Pool"
  echo "4. Delete Network"
  echo "5. Delete Profile"
  echo "6. Delete Image"
  echo "7. Back to Main Menu"

  echo -n "Enter your choice: "
  read choice
  
  case $choice in
    1)
      delete_container
      ;;
    2)
      delete_vm
      ;;
    3)
      delete_storage_pool
      ;;
    4)
      delete_network
      ;;
    5)
      delete_profile
      ;;
    6)
      delete_image
      ;;
    7)
      return
      ;;
    *)
      print_error "Invalid option. Please try again."
      delete_menu
      ;;
  esac
}

# Start the deletion menu
delete_menu

