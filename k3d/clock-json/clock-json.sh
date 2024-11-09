#!/usr/bin/env bash

print_log() {
  local now
  now=$(date -u "+%Y-%m-%dT%H:%M:%S.%3NZ")

  echo "{\"@timestamp\":\"${now}\",\"log.level\":\"INFO\",\"message\":\"Time is ${now}\"}"
}

while true; do
  print_log
  sleep 1
done

