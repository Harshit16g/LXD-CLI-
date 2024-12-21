#!/bin/bash

# Source the utility functions
source ./utils.sh

# Function to move a container to a new location
move_container() {
  container_name=$(prompt_input "Enter the name of the container to move")
  new_location=$(prompt_input "Enter the new location (e.g., /var/lib/lxd/containers)")
  
  print_processing "Moving container $container_name to $new_location"
  lxc move $container_name --target $new_location
  check_command_success "Moving container $container_name"
}

# Function to move a VM to a new location
move_vm() {
  vm_name=$(prompt_input "Enter the name of the VM to move")
  new_location=$(prompt_input "Enter the new location (e.g., /var/lib/lxd/vms)")
  
  print_processing "Moving VM $vm_name to $new_location"
  lxc move $vm_name --target $new_location
  check_command_success "Moving VM $vm_name"
}

# Function to move a storage pool
move_storage_pool() {
  pool_name=$(prompt_input "Enter the name of the storage pool to move")
  new_location=$(prompt_input "Enter the new location (e.g., /mnt/storage_pool)")
  
  print_processing "Moving storage pool $pool_name to $new_location"
  lxc storage move $pool_name --target $new_location
  check_command_success "Moving storage pool $pool_name"
}

# Function to move a network
move_network() {
  network_name=$(prompt_input "Enter the name of the network to move")
  new_location=$(prompt_input "Enter the new location (e.g., /etc/lxd/networks)")
  
  print_processing "Moving network $network_name to $new_location"
  lxc network move $network_name --target $new_location
  check_command_success "Moving network $network_name"
}

# Function to move an image
move_image() {
  image_name=$(prompt_input "Enter the name of the image to move")
  new_location=$(prompt_input "Enter the new location (e.g., /var/lib/lxd/images)")
  
  print_processing "Moving image $image_name to $new_location"
  lxc image move $image_name --target $new_location
  check_command_success "Moving image $image_name"
}

# Menu for moving resources
move_menu() {
  print_menu_header "Move Resource"
  
  echo "1. Move Container"
  echo "2. Move VM"
  echo "3. Move Storage Pool"
  echo "4. Move Network"
  echo "5. Move Image"
  echo "6. Back to Main Menu"

  echo -n "Enter your choice: "
  read choice
  
  case $choice in
    1)
      move_container
      ;;
    2)
      move_vm
      ;;
    3)
      move_storage_pool
      ;;
    4)
      move_network
      ;;
    5)
      move_image
      ;;
    6)
      return
      ;;
    *)
      print_error "Invalid option. Please try again."
      move_menu
      ;;
  esac
}

# Start the move menu
move_menu

