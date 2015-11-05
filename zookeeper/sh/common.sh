#!/bin/bash
#
# File:         common.sh
# Description:  This script provides shared variables and utility functions.

# Make the operating system of this host available as $OS.
OS_UNKNOWN="os-unknown"
OS_MAC="mac"
OS_LINUX="linux"
case `uname` in
  Linux*)
    OS=$OS_LINUX
    ;;
  Darwin*)
    OS=$OS_MAC
    ;;
  *)
    OS=$OS_UNKNOWN
    ;;
esac

# Colors for shell output
if [ "$OS" = "$OS_MAC" ]; then
  red='\x1B[1;31m'
  green='\x1B[1;32m'
  yellow='\x1B[1;33m'
  blue='\x1B[1;34m' nocolor='\x1B[0m'
else
  red='\e[1;31m'
  green='\e[1;32m'
  yellow='\e[1;33m'
  blue='\e[1;34m'
  nocolor='\e[0m'
fi

function puts() {
  local opts=''
  if [ "$1" = "-n" ]; then
    opts='-n'
    shift
  fi
  msg="$@"
  echo -e $opts "${blue}${msg}${nocolor}"
}

function warn() {
  local opts=''
  if [ "$1" = "-n" ]; then
    opts='-n'
    shift
  fi
  msg="$@"
  echo -e $opts "${yellow}${msg}${nocolor}"
}

function error() {
  local opts=''
  if [ "$1" = "-n" ]; then
    opts='-n'
    shift
  fi
  msg="$@"
  echo -e $opts "${red}${msg}${nocolor}"
}

function success() {
  local opts=''
  if [ "$1" = "-n" ]; then
    opts='-n'
    shift
  fi
  msg="$@"
  echo -e $opts "${green}${msg}${nocolor}"
}
