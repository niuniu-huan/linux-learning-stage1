# Linux Learning Stage 1

Hands-on Linux foundation for robotics and embedded systems.

## Environment

- Windows 11 with WSL 2
- Ubuntu 24.04 LTS
- Visual Studio Code with Remote - WSL

## Contents

- `system_info.sh`: Collects CPU, memory, disk, uptime, and USB device information.
- `logs/`: Sample logs. Timestamped system reports are ignored by Git.
- `Linux学习笔记.md`: Detailed learning notes.
- `vim_note.txt`: Vim practice file.

## Run

```bash
chmod u+x system_info.sh
./system_info.sh
./system_info.sh --help
```

## Topics Covered

- Linux filesystem, permissions, processes, logs, and package management
- Bash scripts, arguments, exit codes, and environment variables
- Git, GitHub SSH authentication, and tmux
- VS Code Remote - WSL
- Device files and serial-port permissions

## Next Steps

- C and C++ fundamentals
- Serial communication and CAN
- Embedded Linux and ROS 2