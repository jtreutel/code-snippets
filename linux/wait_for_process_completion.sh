#!/bin/bash
#Tried to use commands that will work on all Linux distros.  ps -C doesn't work on MacOS.

PROGRAM=sleep

if ps -C "$PROGRAM" > /dev/null
then
  echo "Process $PROGRAM is running!"
  PID=$(ps -C $PROGRAM -o pid= | sed 's/\ //g')
  while kill -0 "$PID" 2>/dev/null; do
    echo "Waiting for process $PROGRAM (PID $PID) to complete..."
    sleep 5
  done
  echo "Process $PROGRAM exited!"
else
  echo "Process $PROGRAM is not running!"
fi