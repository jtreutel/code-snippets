#!/bin/bash
sleep 3
echo "Timestamp             | CPU    | Mem" | tee /tmp/cpu_mem_util.log
while true; do
    echo $(date +"%D %T %Z") \| $(top -bn1 | sed -n '/Cpu/p' | awk '{printf "'%05.2f'", 100.0 - $8}')%  \| $(free | grep Mem | awk '{printf "'%05.2f'", $3/$2 * 100.0}')% | tee -a /tmp/cpu_mem_util.log
    sleep 1
done