#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

TRIALS=10

node server.js &
SERVER_PID=$!
sleep 1

echo "::group::warmup"
node client.js > /dev/null
echo "::endgroup::"

client_times=()
crossover_times=()

for i in $(seq 1 "$TRIALS"); do
  start=$(date +%s%N)
  node client.js > /dev/null
  end=$(date +%s%N)
  client_times+=( $(( (end - start) / 1000000 )) )

  start=$(date +%s%N)
  node crossover.js > /dev/null
  end=$(date +%s%N)
  crossover_times+=( $(( (end - start) / 1000000 )) )
done

kill "$SERVER_PID"

echo "::group::client.js trials (ms)"
printf '%s\n' "${client_times[@]}"
echo "::endgroup::"

echo "::group::crossover.js trials (ms)"
printf '%s\n' "${crossover_times[@]}"
echo "::endgroup::"

echo "::group::summary"
printf '%s\n' "${client_times[@]}" | awk '{sum+=$1; if(NR==1||$1<min)min=$1; if($1>max)max=$1} END{printf "client.js:    n=%d mean=%.1fms min=%dms max=%dms\n", NR, sum/NR, min, max}'
printf '%s\n' "${crossover_times[@]}" | awk '{sum+=$1; if(NR==1||$1<min)min=$1; if($1>max)max=$1} END{printf "crossover.js: n=%d mean=%.1fms min=%dms max=%dms\n", NR, sum/NR, min, max}'
echo "::endgroup::"
