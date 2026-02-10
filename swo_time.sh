#!/bin/bash
set -e

FIFO=/dev/shm/swo.fifo
HCLK=72000000
SWO=1000000

# создать FIFO если нет
if [ ! -p "$FIFO" ]; then
    mkfifo -m 600 "$FIFO"
fi

openocd \
  -f interface/stlink.cfg \
  -f target/stm32f1x.cfg \
  -c "tcl_port disabled" \
  -c "init" \
  -c "tpiu config internal $FIFO uart off $HCLK $SWO" \
  -c "itm ports on" \
  -c "reset run" &

OPENOCD_PID=$!

cleanup() {
    echo
    echo -e "\033[33mStopping OpenOCD...\033[0m"
    kill $OPENOCD_PID 2>/dev/null || true
    rm -f "$FIFO"
}
trap cleanup EXIT INT TERM

# SWO с таймстампом в UTC
stdbuf -oL cat "$FIFO" | while IFS= read -r line; do
    echo "[$(date -u '+%H:%M:%S UTC')] $line"
done