#!/bin/bash

# This script updates fence agent descriptions (XML files in src_xml
# directory). Running this will install and update fence agent
# packages to the latest version.

set -exuo pipefail

generator_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$generator_dir/variables.sh"

all_pkgs=''
for cmd_pkg in "${cmd_pkg_map[@]}"; do
    pkg=${cmd_pkg#*:}
    all_pkgs+="$pkg "
done

sudo yum -y install $all_pkgs
sudo yum -y update $all_pkgs

for cmd_pkg in "${cmd_pkg_map[@]}"; do
    cmd=${cmd_pkg%%:*}

    $cmd -o metadata > "$generator_dir/src_xml/$cmd.xml"
done
