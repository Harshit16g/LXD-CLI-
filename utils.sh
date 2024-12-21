#!/bin/bash

# Function to print menu header with a title
print_menu_header() {
  echo -e "\033[1;36m-----------------------------------\033[0m"
  echo -e "\033[1;36m$1\033[0m"
  echo -e "\033[1;36m-----------------------------------\033[0m"
}

# Function to print success message (Green)
print_success() {
  echo -e "\033[1;32m[SUCCESS] \033[0m$1"
}

# Function to print error message (Red)
print_error() {
  echo -e "\033[1;31m[ERROR] \033[0m$1"
}

# Function to print warning message (Yellow)
print_warning() {
  echo -e "\033[1;33m[WARN] \033[0m$1"
}

# Function to print processing message (Blue)
print_processing() {
  echo -e "\033[1;34m[PROCESSING] \033[0m$1"
}

# Function to print informational message (Cyan)
print_info() {
  echo -e "\033[1;36m[INFO] \033[0m$1"
}

# Function to check if a command executed successfully
check_command_success() {
  if [[ $? -eq 0 ]]; then
    print_success "$1 completed successfully."
  else
    print_error "Error occurred while $1."
  fi
}

# Function to display a prompt message before accepting user input
prompt_input() {
  echo -n "$1: "
  read input
  echo $input
}

# Function to check if a container or resource exists
check_container_exists() {
  lxc list --format=csv | grep -q "^$1," && return 0 || return 1
}

# Function to check if a VM or resource exists
check_vm_exists() {
  lxc list --format=csv | grep -q "^$1," && return 0 || return 1
}

# Function to list all available LXD containers and VMs
list_resources() {
  print_info "Listing all containers and VMs..."
  lxc list
}

# Function to stop a container or VM if it's running
stop_resource() {
  print_processing "Stopping resource: $1"
  lxc stop $1
  check_command_success "Stopping $1"
}

# Function to start a container or VM if it's stopped
start_resource() {
  print_processing "Starting resource: $1"
  lxc start $1
  check_command_success "Starting $1"
}

# Function to restart a container or VM
restart_resource() {
  print_processing "Restarting resource: $1"
  lxc restart $1
  check_command_success "Restarting $1"
}

# Function to show the status of a container or VM
show_status() {
  print_info "Fetching status for resource: $1"
  lxc info $1
}

# Function to print a success message after an operation completes
operation_completed() {
  print_success "Operation completed for $1."
}

# Function to print a message when an operation is skipped
operation_skipped() {
  print_warning "Operation skipped for $1."
}

# Function to display a confirmation prompt
confirmation_prompt() {
  echo -n "$1 (y/n): "
  read confirm
  if [[ $confirm == "y" || $confirm == "Y" ]]; then
    return 0
  else
    return 1
  fi
}

# Function to wait for a resource (container/VM) to stop
wait_for_stop() {
  print_processing "Waiting for $1 to stop..."
  while lxc info $1 | grep -q "Status:.*Running"; do
    sleep 1
  done
  print_success "$1 has stopped."
}

# Function to wait for a resource (container/VM) to start
wait_for_start() {
  print_processing "Waiting for $1 to start..."
  while ! lxc info $1 | grep -q "Status:.*Running"; do
    sleep 1
  done
  print_success "$1 is running."
}

# Function to handle a safe shutdown of a container or VM
safe_shutdown() {
  if confirmation_prompt "Are you sure you want to stop $1?"; then
    stop_resource $1
    wait_for_stop $1
  else
    operation_skipped "stopping $1"
  fi
}

# Function to safely start a container or VM
safe_start() {
  if confirmation_prompt "Are you sure you want to start $1?"; then
    start_resource $1
    wait_for_start $1
  else
    operation_skipped "starting $1"
  fi
}

# Function to safely restart a container or VM
safe_restart() {
  if confirmation_prompt "Are you sure you want to restart $1?"; then
    restart_resource $1
    wait_for_start $1
  else
    operation_skipped "restarting $1"
  fi
}

# Function to clean up any failed resources
clean_up_failed_resources() {
  print_warning "Cleaning up failed resources..."
  # Placeholder for resource cleanup logic (could delete or fix failed containers)
}


