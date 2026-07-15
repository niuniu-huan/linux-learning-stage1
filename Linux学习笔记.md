# Linux 学习笔记：具身智能与嵌入式方向

> 学习环境：Windows + WSL 2 + Ubuntu 24.04 LTS
>
> 学习目标：先熟练使用 Linux 进行开发、排错和日志分析；后续逐步进入 C/C++、串口/CAN、嵌入式 Linux 与 ROS 2。

## 0. 方向与路线

面向电机、硬件嵌入式与具身智能，推荐按以下顺序学习：

1. Linux 基础：终端、文件系统、权限、软件管理、日志、SSH、Git。
2. 编程与构建：C、C++、Python、GCC、Make、CMake、GDB。
3. 嵌入式 Linux：UART、I2C、SPI、CAN、GPIO、udev、systemd、交叉编译与实时性。
4. 机器人系统：ROS 2、TF、URDF、RViz、ros2_control、仿真与真实硬件接入。

项目主线：单片机电机闭环 -> Linux 通过串口/CAN 控制 -> ROS 2 封装为控制与里程计接口 -> 两轮小车或关节控制项目。

## 1. 当前环境

- Windows 上已启用 WSL 2 和虚拟化。
- 已安装 Ubuntu 24.04.4 LTS，代号 `noble`。
- Linux 用户：`moqi_`。
- Linux 家目录：`/home/moqi_`，可简写为 `~`。
- WSL 内核：`6.18.33.2-microsoft-standard-WSL2`。

### WSL 中的路径

| Linux 路径 | 含义 |
| --- | --- |
| `/` | Linux 文件系统的根目录。注意：它不是管理员账户 `root`。 |
| `/home/moqi_` 或 `~` | 当前用户的家目录，代码和 Linux 项目建议放在这里。 |
| `/mnt/c` | Windows C 盘在 WSL 中的映射。 |
| `/etc` | 系统配置文件。 |
| `/dev` | 设备接口。未来常见串口设备如 `/dev/ttyUSB0`。 |
| `/var/log` | 系统日志。 |
| `/proc` | 内核和进程状态信息的虚拟文件系统。 |

代码、C/C++ 编译产物和 ROS 2 工作区优先放在 Linux 家目录，避免放在 `/mnt/c`，以减少权限与性能差异。

## 2. 终端与文件操作

### 已用命令

```bash
whoami                 # 显示当前用户名
pwd                    # 显示当前所在目录
cd ~                   # 回到家目录
cd /                   # 进入根目录
cd ..                  # 进入上一级目录
ls                     # 查看目录内容
ls -l                  # 详细列表
ls -la                 # 详细列表，含隐藏文件
mkdir -p 路径          # 创建目录；上级目录不存在时一并创建
touch 文件名           # 创建空文件
cat 文件名             # 显示文件内容
cp 源文件 目标文件      # 复制文件
mv 源文件 目标文件      # 重命名或移动文件
rm 文件名              # 删除文件，Linux 默认没有回收站
```

### 重定向与通配符

```bash
echo "内容" > 文件名       # 覆盖写入文件
echo "内容" >> 文件名      # 追加到文件末尾
ls logs/system_info_*.log  # * 表示任意字符
```

命令正常成功时通常没有输出，重新出现提示符即可继续。命令拼写错误会出现 `command not found`，先检查拼写，不要直接按照系统的通用提示安装未知软件包。

### 当前练习目录

```text
~/linux_learning/stage1/
├── linux_note.txt
├── motor_note.txt
├── ros2_learning_note.txt
├── logs/
│   ├── motor.log
│   ├── robot.log
│   └── system_info_时间戳.log
└── system_info.sh
```

## 3. 查找文件与日志内容

```bash
find . -type f                     # 从当前目录递归查找普通文件
grep -n "motor" logs/motor.log     # 查找文字并显示行号
grep -Rni "motor" .                # 递归查找；忽略大小写；显示行号
wc -l 文件名                        # 统计行数
head -n 8 文件名                    # 查看前 8 行
tail -n 10 文件名                   # 查看后 10 行
grep -nE "A|B" 文件名              # 用多个关键词搜索
```

管道 `|` 会将前一个命令的输出交给后一个命令，例如：

```bash
gcc --version | head -n 1
history | tail -n 12
```

## 4. 软件管理与常用工具

`sudo` 表示以管理员权限执行命令。只在理解命令作用时使用。

```bash
sudo apt update                     # 更新可安装软件的目录信息
sudo apt upgrade                    # 升级已安装的软件包
sudo apt install 软件包名            # 安装软件包
```

已安装的基础工具：

| 工具 | 用途 |
| --- | --- |
| `tree` | 树状显示目录结构。 |
| `git` | 代码版本管理。 |
| `build-essential` | C/C++ 基础编译工具：GCC、G++、Make 等。 |
| `cmake` | C/C++ 和 ROS 2 常用构建工具。 |
| `python3-pip` | Python 第三方包管理。 |
| `htop` | 动态查看进程、CPU 与内存。按 `q` 退出。 |
| `ripgrep` / `rg` | 高效搜索代码和日志。 |
| `usbutils` / `lsusb` | 查看 Linux 可见的 USB 设备。 |
| `nano` | 终端文本编辑器。 |
| `tmux` | 已安装，版本 3.4；用于持久终端会话。 |

## 5. Shell 脚本项目：系统巡检日志

已创建并运行：`~/linux_learning/stage1/system_info.sh`。

脚本完成的工作：

1. 读取当前时间、用户、主机名和内核版本。
2. 使用 `lscpu` 输出 CPU 信息。
3. 使用 `free -h` 输出内存信息。
4. 使用 `df -h` 输出磁盘信息。
5. 使用 `lsusb` 输出 USB 设备信息。
6. 使用 `tee` 同时在终端显示结果、写入带时间戳的日志文件。

下一次脚本改进：在 `[User and Host]` 区域加入 `uptime -p` 的输出。`uptime -p` 会给出人类易读的系统运行时长，例如 `up 10 hours, 30 minutes`，用于判断机器人主机或控制程序所在设备已连续运行多久。

已完成改进：`system_info.sh` 的 `[User and Host]` 区域新增：

```bash
echo "Uptime: $(uptime -p)"
```

脚本已验证能够输出系统运行时长并生成新日志。

### 可执行权限

```bash
ls -l system_info.sh
chmod u+x system_info.sh
./system_info.sh
```

`./` 表示从当前目录执行该脚本。Linux 默认不会自动从当前目录查找可执行文件。

### WSL 与 USB

脚本中 `[USB Devices]` 为空是正常现象。WSL 默认不能直接访问 Windows 上的 USB 设备。未来连接 STM32、USB 转串口或 CAN 适配器时，需要使用 Windows 的 `usbipd` 将指定 USB 设备转发给 WSL；进入串口/CAN 实践时再配置。

## 6. 进程、服务与系统日志

```bash
ps -ef | head -n 10                # 查看进程列表
free -h                            # 查看内存与 swap
df -h                              # 查看磁盘和挂载点
htop                               # 交互式查看系统资源
systemctl status cron --no-pager   # 查看服务状态
sudo journalctl -u cron -b --no-pager | tail -n 20
```

当前 WSL 中 `systemd` 作为 PID 1 运行，因此可以使用 `systemctl` 和 `journalctl`。以后将机器人控制程序配置为服务时，常用排错方式是：

```bash
systemctl status 服务名
journalctl -u 服务名 -b
```

## 7. 用户、用户组与权限

```bash
id
groups
ls -ld 目录名
ls -l 文件名
```

文件权限字段例如：

```text
-rwxr--r--
```

- 第一个字符：`-` 表示普通文件，`d` 表示目录。
- 后面三组依次代表文件拥有者、所属组、其他用户的权限。
- `r` 为读取，`w` 为写入，`x` 为执行；目录上的 `x` 表示可以进入或穿过该目录。

当前用户属于 `sudo` 组，可以使用 `sudo`。当前尚未加入 `dialout` 组；之后访问串口设备时，通常需检查设备所属组并在必要时执行：

```bash
sudo usermod -aG dialout $USER
```

该命令会改变用户组，只有真实串口设备需要时再执行，并在重新登录或重启 WSL 后生效。

## 8. Git 基础

已在 `~/linux_learning/stage1` 创建 Git 仓库，默认分支为 `main`。

Git 的标准工作循环：

```bash
git status                         # 查看当前状态
git diff                           # 查看未暂存的改动
git add 文件名                     # 将指定文件加入暂存区
git commit -m "提交说明"            # 创建提交
git log --oneline                  # 查看简洁提交历史
```

已创建 `.gitignore`，忽略自动生成的巡检日志：

```text
logs/system_info_*.log
```

已完成的提交：

```text
787b55f Add Git learning note
fb24c4a Complete Linux stage 1 basics
```

当 `git status` 显示 `working tree clean`，表示当前文件状态与最新提交一致。`git restore` 可以丢弃未暂存改动，只有确定不再需要改动时才使用。

`git diff` 在输出较长时会进入翻页器；看到末尾 `:` 时按 `q` 退出并回到终端。

## 9. 命令帮助

```bash
命令 --help
man 命令
```

`man` 会进入手册阅读界面，按 `q` 退出。已练习 `man chmod`。

## 10. 网络与 SSH

已确认 WSL 的网络与 SSH 客户端可用：

```bash
hostname                           # 当前 Linux 主机名
hostname -I                        # WSL 虚拟网络地址
ip route                           # 路由与默认网关
getent hosts archive.ubuntu.com    # DNS 解析测试
ssh -V                             # SSH 客户端版本
```

当前 WSL 虚拟 IP 为 `172.28.34.91`，默认网关为 `172.28.32.1`。WSL 的 IP 可能随重启变化，通常不能视为局域网固定 IP。

SSH 是以后连接 Jetson、机器人主控、工控机和远程 Ubuntu 服务器的主要方式。当前只确认了客户端可用，尚未连接远程主机。

### GitHub SSH 密钥（进行中）

GitHub 邮箱可作为 SSH 密钥的备注；GitHub 用户名不影响密钥生成。生成前必须检查已有密钥，避免覆盖：

```bash
ls -la ~/.ssh
```

后续会生成 Ed25519 密钥对。`~/.ssh/id_ed25519` 是私钥，必须只保留在本机，不能粘贴、上传或发送给任何人；只有 `~/.ssh/id_ed25519.pub` 是可添加到 GitHub 的公钥。

检查结果：当前不存在 `~/.ssh` 目录，说明尚未创建 SSH 密钥，可安全使用默认路径 `~/.ssh/id_ed25519`。

已生成 Ed25519 密钥对。生成结束时显示的 `SHA256` 指纹和随机图案（randomart）用于识别公钥，不是错误，也不泄露私钥。

查看密钥文件与公钥：

```bash
ls -l ~/.ssh
cat ~/.ssh/id_ed25519.pub
```

只允许查看和复制 `.pub` 公钥；绝不执行 `cat ~/.ssh/id_ed25519`，也绝不上传私钥。

已将 `id_ed25519.pub` 作为 `Authentication Key` 添加到 GitHub 账号。下一步使用 `ssh -T git@github.com` 测试连接。

已完成测试：首次连接时核对 GitHub 的 ED25519 主机指纹并输入 `yes`，系统将 GitHub 主机记录保存到 `~/.ssh/known_hosts`；输入私钥口令后，GitHub 返回 `Hi niuniu-huan! You've successfully authenticated`，说明 SSH 密钥认证成功。GitHub 不提供交互式 shell，这条提示是正常的。

为当前终端启动 SSH agent 并载入私钥：

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

`ssh-add` 成功后，当前终端再次执行 `ssh -T git@github.com` 不需要重复输入私钥口令。该 agent 仅对当前 WSL 会话有效，重启 WSL 后需要重新启动并重新载入密钥。

### 发布到 GitHub（准备中）

计划将本地 `~/linux_learning/stage1` 发布为公开仓库，用于保留学习过程和后续作品。因为本地仓库已有两次提交，GitHub 新建仓库时不能初始化 README、`.gitignore` 或许可证；创建空仓库后再添加远程地址并推送。

已在 GitHub 创建公开空仓库：`niuniu-huan/linux-learning-stage1`。待发布前使用 `git status` 和 `git ls-files` 检查工作区状态与将被公开的受跟踪文件。

已完成首次推送：SSH 远程地址为 `git@github.com:niuniu-huan/linux-learning-stage1.git`，本地 `main` 已跟踪 `origin/main`。推送前确认工作区干净，已发布 13 个 Git 对象。

注意：本学习笔记目前保存于 Windows 工作文件夹 `C:\\Users\\moqi_\\Desktop\\learning\\linux_learning\\Linux学习笔记.md`，而 Git 仓库位于 WSL 的 `~/linux_learning/stage1`；两者不在同一目录，因此笔记尚未随本次推送自动上传。若需要将笔记公开到仓库，需要先复制到仓库、提交并推送。

已确认：将本笔记公开发布到 `niuniu-huan/linux-learning-stage1`。下一步从 `/mnt/c/Users/moqi_/Desktop/learning/linux_learning/` 复制到 WSL 仓库，再以 Git 提交。

已完成首次笔记发布，提交为 `f1c83d0 Add Linux learning notes`。Git 在终端中显示中文文件名时可能使用 `\345...` 形式转义，这不影响真实文件名。Markdown 文件应为普通文本权限 `644`，不应带可执行权限；同步时使用 `chmod 644 Linux学习笔记.md` 修正。

## 12. VS Code 与 WSL（进行中）

已确认 WSL 中 `code` 命令可用，Visual Studio Code 版本为 `1.128.0`。在 Linux 项目目录运行：

```bash
code .
```

可将当前 WSL 目录直接作为 VS Code 工作区打开。编辑器左下角应显示 WSL/Ubuntu 远程环境；此时内置终端、文件操作、Git、编译器和后续 ROS 2 工具均在 Ubuntu 中运行，而不是在 Windows PowerShell 中运行。

已成功打开 `stage1` 工作区，资源管理器可见脚本、日志和学习笔记。若 VS Code 显示“受限模式”，对于自己创建并确认安全的学习目录可通过顶部横幅的“管理”选择信任该文件夹，以启用终端、Git、扩展等完整功能。截图标题中的“管理员”表示 Windows 上的 VS Code 以管理员权限运行；日常开发不需要管理员权限，后续应以普通方式启动 VS Code，避免产生权限不一致的问题。

### 本地 UNC 浏览与 Remote - WSL 的区别

若 VS Code 内置终端提示符为 `PS ... \\wsl.localhost\\Ubuntu-24.04\\...>`，说明当前是 Windows PowerShell 通过 UNC 路径浏览 WSL 文件，不是 Remote - WSL。此时不能直接运行 Linux 的 `.sh` 文件。

正确的 Remote - WSL 终端提示符应类似：

```text
moqi_@moqihuan:~/linux_learning/stage1$
```

需要安装并使用 Microsoft 的 `Remote - WSL` 扩展，打开远程 Ubuntu 窗口后再运行 Linux 命令。

若扩展市场显示 `Failed to fetch`，说明 VS Code 无法访问 Marketplace，通常与网络、代理或 TLS 拦截有关，不是 WSL 本身的错误。可先从 Ubuntu 终端使用下列命令尝试安装并获得明确输出：

```bash
code --install-extension ms-vscode-remote.remote-wsl
```

若仍失败，再检查 VS Code 的网络/代理设置或改用官方 VSIX 离线安装包。

已成功切换到 Remote - WSL：VS Code 左下角显示 `WSL: Ubuntu-24.04`，内置终端显示 `moqi_@moqihuan:~/linux_learning/stage1$`。这两个标志确认命令会在 Ubuntu 中执行。

## 11. tmux（进行中）

已确认安装：`tmux 3.4`。

目标：创建一个持久终端会话、暂时分离会话、重新连接会话；以后即使 SSH 断开，也能保留正在运行的编译、日志或 ROS 2 任务。

### 使用位置与基本流程

`tmux` 安装在 Ubuntu 中，必须在 Ubuntu/WSL 终端执行，不能在 Windows PowerShell (`PS C:\\...>`) 中直接执行。

```bash
tmux new -s linux-study       # 创建并进入命名会话
# 在会话中工作
# 按 Ctrl+B，松开后按小写 d：分离会话
tmux ls                       # 查看会话
tmux attach -t linux-study    # 重新进入会话
```

`Ctrl+C` 是中断当前前台命令，不是分离 tmux 的快捷键。`Ctrl+B` 后必须按小写 `d`；大写 `D` 会进入客户端选择界面，按 `q` 可退出该界面。看到 `[detached and SIGHUP ...]` 时，tmux 会话可能仍在后台；应先在 Ubuntu 中执行 `tmux ls` 确认，不要直接重复创建。

已完成练习：创建 `linux-study` 会话、在其中执行命令、使用 `Ctrl+B` 后小写 `d` 分离，并通过 `tmux ls` 确认会话仍在后台运行；随后已使用 `tmux attach -t linux-study` 重新连接并再次分离。

不再需要会话时可以使用 `tmux kill-session -t linux-study` 结束它；当前练习会话暂时保留，不执行该命令。

---

本笔记会在每完成一个新主题后持续补充。
