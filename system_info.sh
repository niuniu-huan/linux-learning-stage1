#!/usr/bin/env bash

LOG_DIR="$HOME/linux_learning/stage1/logs"
LOG_FILE="$LOG_DIR/system_info_$(date +%F_%H-%M-%S).log"

{
    echo "=== System Information ==="
    echo "Time: $(date)"
    echo

    echo "[User and Host]"
    echo "User: $(whoami)"
    echo "Host: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo

    echo "[CPU]"
    lscpu | grep -E "Model name|CPU\(s\)"
    echo

    echo "[Memory]"
    free -h
    echo

    echo "[Disk]"
    df -h "$HOME"
    echo

    echo "[USB Devices]"
    lsusb
} | tee "$LOG_FILE"

echo
echo "Log saved to: $LOG_FILE"
