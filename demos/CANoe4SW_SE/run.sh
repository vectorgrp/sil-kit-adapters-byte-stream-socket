#!/bin/bash
# SPDX-FileCopyrightText: Copyright 2025 Vector Informatik GmbH
# SPDX-License-Identifier: MIT

script_root=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
canoe4sw_se_install_dir="/opt/vector/canoe-server-edition/"

export canoe4sw_se_install_dir

$script_root/createEnvironment.sh

#run tests
$canoe4sw_se_install_dir/canoe4sw-se "$script_root/Default.venvironment" -d "$script_root/working-dir" --verbosity-level "2" --test-unit "$script_root/testBytestreamSocketEchoDemo.vtestunit"  --show-progress "tree-element"
