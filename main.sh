#!/bin/bash

# Source utility functions
source ./utils.sh

# Function to display the main menu
main_menu() {
  print_menu_header "LXD Management CLI"

  echo "1. Create Resources (Container, VM, etc.)"
  echo "2. Delete Resources (Container, VM, etc.)"
  echo "3. Manage Resources (Start, Stop, Restart, Status)"
  echo "4. Move Resources (Containers, VMs)"
  echo "5. List Resources (Containers, VMs, Snapshots)"
  echo "6. Configure Resources"
  echo "7. Cluster Operations"
  echo "8. Snapshot Operations"
  echo "9. Operations (Start, Stop, Restart, Status)"
  echo "10. Exit"

  echo -n "Enter your choice: "
  read choice

  case $choice in
    1)
      source ./create.sh
      create_menu
      ;;
    2)
      source ./delete.sh
      delete_menu
      ;;
    3)
      source ./manage.sh
      manage_menu
      ;;
    4)
      source ./move.sh
      move_menu
      ;;
    5)
      source ./list.sh
      list_menu
      ;;
    6)
      source ./configure.sh
      configure_menu
      ;;
    7)
      source ./cluster.sh
      cluster_menu
      ;;
    8)
      source ./snapshot.sh
      snapshot_menu
      ;;
    9)
      source ./operations.sh
      operations_menu
      ;;
    10)
      print_success "Exiting LXD Management CLI."
      exit 0
      ;;
    *)
      print_error "Invalid option. Please try again."
      main_menu
      ;;
  esac
}

# Ensure all relevant functions are run with sudo
create_container() {
  sudo lxc launch ubuntu:20.04 $1
}

delete_container() {
  sudo lxc delete $1
}

manage_container() {
  sudo lxc start $1
  sudo lxc stop $1
  sudo lxc restart $1
  sudo lxc info $1
}

move_container() {
  sudo lxc move $1 $2
}

list_resources() {
  sudo lxc list
}

configure_container() {
  sudo lxc config device add $1 eth0 nic
}

cluster_operations() {
  sudo lxd init --auto
}

snapshot_operations() {
  sudo lxc snapshot $1 $2
}

operations() {
  sudo lxc exec $1 -- /bin/bash
}

# Start the main menu
main_menu

