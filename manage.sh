#!/bin/bash

# Source the utility functions
source ./utils.sh

# Function to start a container or VM
start_container_or_vm() {
  name=$(prompt_input "Enter the name of the container or VM to start")
  print_processing "Starting $name"
  lxc start $name
  check_command_success "Starting $name"
}

# Function to stop a container or VM
stop_container_or_vm() {
  name=$(prompt_input "Enter the name of the container or VM to stop")
  print_processing "Stopping $name"
  lxc stop $name
  check_command_success "Stopping $name"
}

# Function to restart a container or VM
restart_container_or_vm() {
  name=$(prompt_input "Enter the name of the container or VM to restart")
  print_processing "Restarting $name"
  lxc restart $name
  check_command_success "Restarting $name"
}

# Function to list all containers and VMs
list_containers_and_vms() {
  print_processing "Listing all containers and VMs"
  lxc list
  check_command_success "Listing all containers and VMs"
}

# Function to show status of a container or VM
show_status() {
  name=$(prompt_input "Enter the name of the container or VM")
  print_processing "Showing status of $name"
  lxc info $name
  check_command_success "Showing status of $name"
}

# Function to resize a container or VM's root disk
resize_disk() {
  name=$(prompt_input "Enter the name of the container or VM to resize")
  size=$(prompt_input "Enter the new size (e.g., 10GB)")
  print_processing "Resizing root disk of $name to $size"
  lxc config device set $name root size $size
  check_command_success "Resizing root disk of $name"
}

# Function to attach a new disk to a container or VM
attach_disk() {
  name=$(prompt_input "Enter the name of the container or VM to attach disk")
  disk_name=$(prompt_input "Enter the name of the disk")
  disk_size=$(prompt_input "Enter the size of the disk (e.g., 10GB)")
  print_processing "Attaching disk $disk_name of size $disk_size to $name"
  lxc storage volume create default $disk_name size=$disk_size
  lxc config device add $name $disk_name disk source=$disk_name path=/mnt/$disk_name
  check_command_success "Attaching disk $disk_name to $name"
}

# Function to detach a disk from a container or VM
detach_disk() {
  name=$(prompt_input "Enter the name of the container or VM to detach disk")
  disk_name=$(prompt_input "Enter the name of the disk to detach")
  print_processing "Detaching disk $disk_name from $name"
  lxc config device remove $name $disk_name
  lxc storage volume delete default/$disk_name
  check_command_success "Detaching disk $disk_name from $name"
}

# Menu for managing resources
manage_menu() {
  print_menu_header "Manage Resource"
  
  echo "1. Start Container or VM"
  echo "2. Stop Container or VM"
  echo "3. Restart Container or VM"
  echo "4. List Containers and VMs"
  echo "5. Show Status of Container or VM"
  echo "6. Resize Disk of Container or VM"
  echo "7. Attach Disk to Container or VM"
  echo "8. Detach Disk from Container or VM"
  echo "9. Back to Main Menu"

  echo -n "Enter your choice: "
  read choice
  
  case $choice in
    1)
      start_container_or_vm
      ;;
    2)
      stop_container_or_vm
      ;;
    3)
      restart_container_or_vm
      ;;
    4)
      list_containers_and_vms
      ;;
    5)
      show_status
      ;;
    6)
      resize_disk
      ;;
    7)
      attach_disk
      ;;
    8)
      detach_disk
      ;;
    9)
      return
      ;;
    *)
      print_error "Invalid option. Please try again."
      manage_menu
      ;;
  esac
}

# Start the management menu
manage_menu

