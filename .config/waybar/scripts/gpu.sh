#!/usr/bin/env bash
emit() {  # util% temp_C vram_used_MiB vram_total_MiB
  local u t mu mt cls=""
  u=$(printf '%.0f' "${1:-0}")
  t=$(printf '%.0f' "${2:-0}")
  mu=$(printf '%.0f' "${3:-0}")
  mt=$(printf '%.0f' "${4:-0}")
  if   (( t >= 85 )); then cls="critical"
  elif (( t >= 75 )); then cls="warning"; fi
  printf '{"text":"%s%% %s°C","tooltip":"GPU: %s%%\\nTemp: %s°C\\nVRAM: %s / %s MiB","class":"%s"}\n' \
    "$u" "$t" "$u" "$t" "$mu" "$mt" "$cls"
}

if command -v nvidia-smi >/dev/null 2>&1; then
  out=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total \
        --format=csv,noheader,nounits | head -n1)
  read -r u t mu mt <<< "${out//,/ }"
  emit "$u" "$t" "$mu" "$mt"
  exit 0
fi

for d in /sys/class/drm/card?/device; do
  [ -r "$d/gpu_busy_percent" ] || continue
  u=$(<"$d/gpu_busy_percent")
  t=$(cat "$d"/hwmon/hwmon*/temp1_input 2>/dev/null | head -n1)
  mu=$(<"$d/mem_info_vram_used")
  mt=$(<"$d/mem_info_vram_total")
  emit "$u" "$(( ${t:-0} / 1000 ))" "$(( mu / 1048576 ))" "$(( mt / 1048576 ))"
  exit 0
done

echo '{"text":"n/a","tooltip":"No supported GPU found"}'
