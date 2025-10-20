#!/bin/bash
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
logdir=$scriptDir/logs
silKitDir=/home/vector/SilKit/SilKit-5.0.1-ubuntu-22.04-x86_64-gcc/
# if "exported_full_path_to_silkit" environment variable is set (in pipeline script), use it. Otherwise, use default value
silKitDir="${exported_full_path_to_silkit:-$silKitDir}"

# cleanup trap for child processes 
trap 'children=$(pstree -A -p $$); echo "$children" | grep -Eow "[0-9]+" | grep -v $$ | xargs kill &>/dev/null; exit' EXIT SIGHUP;

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
timeout 30s grep -q 'Registered signal handler' <(tail -f $logdir/sil-kit-registry.out -n +1) || { echo "[error] Timeout reached while waiting for sil-kit-registry to start"; exit 1; }

echo "[info] Starting socat"
( while true; do echo "test"; sleep 1; done | socat - TCP4-LISTEN:23456,reuseaddr >/dev/null )&

echo "[info] Starting the adapter"
#Using bash printf to dissect complex & large argument
$scriptDir/../../bin/sil-kit-adapter-byte-stream-socket \
  "--socket-to-byte-stream" \
    $(printf '%s' \
      'localhost:23456,' \
      'toSocket,' \
      'fromSocket') \
  "--log" "Debug" &> $logdir/sil-kit-adapter-byte-stream-socket.out &

echo "[info] Starting the echo participant"
$scriptDir/../../bin/sil-kit-demo-byte-stream-echo-device --log Debug &> $logdir/sil-kit-demo-byte-stream-echo-device.out &

echo "[info] Starting run.sh test script"
$scriptDir/run.sh &>$logdir/run.sh.out
echo "Tests finished"

if [[ "$(tail -n 1 "$logdir/run.sh.out")" == *"passed"* ]]; then
    echo "Tests passed"
else
    echo "Tests failed"
fi

#exit run_all.sh with same exit_status
exit $exit_status
