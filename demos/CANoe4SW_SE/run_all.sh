#!/bin/bash
# SPDX-FileCopyrightText: Copyright 2025 Vector Informatik GmbH
# SPDX-License-Identifier: MIT

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
logdir=$scriptDir/logs
silKitDir=/home/vector/SilKit/SilKit-5.0.2-ubuntu-22.04-x86_64-gcc/
# if "exported_full_path_to_silkit" environment variable is set (in pipeline script), use it. Otherwise, use default value
silKitDir="${exported_full_path_to_silkit:-$silKitDir}"

# cleanup trap for child processes 
trap 'kill $(jobs -p) >/dev/null 2>&1 || true; exit' EXIT SIGHUP SIGTERM SIGINT;

if [ ! -d "$silKitDir" ]; then
  echo "[error] The var 'silKitDir' needs to be set to actual location of your SIL Kit"
  exit 1
fi

mkdir $logdir &>/dev/null

# check if user is root
if [[ $EUID -ne 0 ]]; then
  echo "[error] This script must be run as root / via sudo!"
  exit 1
fi

echo "[info] Starting the SIL Kit registry"
$silKitDir/SilKit/bin/sil-kit-registry --listen-uri 'silkit://0.0.0.0:8501' &> $logdir/sil-kit-registry.out &
sleep 1 # wait 1 second for the creation/existense of the .out file
timeout 30s grep -q 'Press Ctrl-C to terminate...' <(tail -f $logdir/sil-kit-registry.out -n +1) || { echo "[error] Timeout reached while waiting for sil-kit-registry to start"; exit 1; }

echo "[info] Starting echo server"
$scriptDir/../../tools/echo_server.sh 23456 &> $logdir/echo_server.out &

sleep 2 # wait for the echo server to start

echo "[info] Starting the adapter"
#Using bash printf to dissect complex & large argument
$scriptDir/../../bin/sil-kit-adapter-byte-stream-socket \
  "--socket-to-byte-stream" \
    $(printf '%s' \
      'localhost:23456,' \
      'toSocket,' \
      'fromSocket') \
  "--log" "Debug" &> $logdir/sil-kit-adapter-byte-stream-socket.out &

echo "[info] Starting run.sh test script"
$scriptDir/run.sh &>$logdir/run.sh.out
exit_status=$?
echo "[info] Tests finished"

if [[ $exit_status -eq 0 ]]; then
  echo "[info] Tests passed"
else
  echo "[error] Tests failed"
fi

#exit run_all.sh with same exit_status
exit $exit_status
