#!/bin/bash

# This scripts generates fence agent manifests from their XML
# descriptions

set -exuo pipefail

generator_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$generator_dir/variables.sh"

for cmd_pkg in "${cmd_pkg_map[@]}"; do
    cmd=${cmd_pkg%%:*}
    pkg=${cmd_pkg#*:}

    "$generator_dir/agent_generator.rb" "$generator_dir/src_xml/$cmd.xml" $cmd $pkg > "$generator_dir/../manifests/stonith/$cmd.pp"
done
