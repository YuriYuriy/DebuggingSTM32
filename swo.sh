#!/bin/bash
set -e

FIFO=/dev/shm/swo.fifo
HCLK=72000000
SWO=1000000

# создать FIFO если нет
if [ ! -p "$FIFO" ]; then
    mkfifo -m 600 "$FIFO"
fi

# запустить OpenOCD в фоне
openocd \
  -f interface/stlink.cfg \
  -f target/stm32f1x.cfg \
  -c "tcl_port disabled" \
  -c "init" \
  -c "tpiu config internal $FIFO uart off $HCLK $SWO" \
  -c "itm ports on" \
  -c "reset run" \
  &

OPENOCD_PID=$!

# корректное завершение
cleanup() {
    echo
    echo "Stopping OpenOCD..."
    kill $OPENOCD_PID 2>/dev/null || true
    rm -f "$FIFO"
}
trap cleanup EXIT INT TERM

# читать SWO
stdbuf -oL cat "$FIFO"
