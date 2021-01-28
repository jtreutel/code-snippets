#!/bin/bash
#Based on https://github.com/mkly/docker-cpu-profiling-orb

DELAY=3
SAMPLE_INTERVAL=1

sleep $DELAY

cpu_shares=$(cat /sys/fs/cgroup/cpu/cpu.shares)

if command -v jq >> /dev/null 2>&1; then
  cpus=$(echo "$cpu_shares / 1024" | jq -nf /dev/stdin)
elif command -v awk >> /dev/null 2>&1; then
  cpus=$(echo - | awk "{print $cpu_shares / 1024}")
fi

quota=$(cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us)
quota_interval=$(cat /sys/fs/cgroup/cpu/cpu.cfs_period_us)

if command -v jq >> /dev/null 2>&1; then
  available_per_micro_second=$(echo "$quota / $quota_interval" | jq -nf /dev/stdin)
elif command -v awk >> /dev/null 2>&1; then
  available_per_micro_second=$(echo - | awk "{print $quota / $quota_interval}")
fi

sample_length_mcs=$(($SAMPLE_INTERVAL * 1000000))

echo CPU util avg over $SAMPLE_INTERVAL second intervals >> /tmp/cpu_util.log
echo >> /tmp/cpu_util.log
echo Timestamp \| CPU Util \(%\) >> /tmp/cpu_util.log

while true; do
  sample_1=$(cat /sys/fs/cgroup/cpuacct/cpuacct.usage_user)
  sleep $SAMPLE_INTERVAL
  sample_2=$(cat /sys/fs/cgroup/cpuacct/cpuacct.usage_user)

  if command -v jq >> /dev/null 2>&1; then
    total_available=$(echo "$available_per_micro_second * $sample_length_mcs" | jq -nf /dev/stdin)
  elif command -v awk >> /dev/null 2>&1; then
    total_available=$(echo - | awk "{print $available_per_micro_second * $sample_length_mcs}")
  fi

  total_used=$(($sample_2 - $sample_1))

  if command -v jq >> /dev/null 2>&1; then
    percent=$(echo "$total_used / $total_available / $cpus" | jq -nf /dev/stdin)
  elif command -v awk >> /dev/null 2>&1; then
    percent=$(echo - | awk "{print $total_used / $total_available / $cpus}")
  fi
  echo $(date +"%D %T %Z") \| ${percent}% >> /tmp/cpu_util.log
done