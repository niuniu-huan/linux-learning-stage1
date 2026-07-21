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

## 13. 命令退出状态与 PATH（进行中）

Linux 命令完成后会返回退出状态：`0` 通常表示成功，非 `0` 表示失败。使用 `$?` 查看上一条命令的退出状态，必须紧跟在目标命令后执行。

```bash
command -v gcc     # 查找命令所在路径
echo $?            # 读取上一条命令的退出状态
```

`PATH` 是 shell 寻找命令的目录列表。以后安装 ROS 2 后，如果 `ros2` 显示 `command not found`，首先检查是否已执行 ROS 环境初始化脚本，以及 `PATH` 是否包含对应目录。

验证结果：`command -v gcc` 返回 `/usr/bin/gcc`，退出状态为 `0`；`command -v ros2` 无输出且退出状态为 `1`，因为当前尚未安装 ROS 2。`PATH` 开头的 `.vscode-server/.../remote-cli` 来自 VS Code Remote - WSL，属于正常环境配置。

### 环境变量

环境变量会影响当前 shell 启动的程序。使用 `export` 创建并导出变量：

```bash
export ROBOT_NAME="demo_bot"
echo "$ROBOT_NAME"
```

ROS 2 的 `setup.bash` 本质上也是一组环境变量初始化；进入 ROS 2 阶段后会用 `source /opt/ros/.../setup.bash` 配置命令、库和包搜索路径。

已验证：导出 `ROBOT_NAME=demo_bot` 后，子 Bash 进程可以读取它；执行 `unset ROBOT_NAME` 后变量不再存在。

## 14. 后台任务与 PID（进行中）

命令末尾的 `&` 会让程序在后台运行。`$!` 代表最近启动的后台任务 PID；`jobs -l` 查看当前 shell 启动的后台任务；`kill PID` 向指定进程发送终止信号。只应终止自己确认无误的进程。

```bash
sleep 300 &
JOB_PID=$!
jobs -l
kill "$JOB_PID"
```

未来调试机器人节点时，可以用这些命令确认测试程序是否仍在运行；长期任务更推荐使用 `tmux` 或 `systemd` 管理。

已完成练习：后台 `sleep` 进程可通过 PID 查看，使用 `kill` 终止后 `jobs -l` 不再显示该任务。`wait` 返回 `143`，表示进程收到 `SIGTERM`（信号编号 15；shell 常以 `128 + 信号编号` 报告被信号终止的状态）。`kill -9` 是强制终止手段，只有常规 `kill` 无效时才考虑使用。

## 15. 设备文件与串口（进行中）

Linux 将很多硬件和内核接口表示为 `/dev` 下的文件。设备列表的权限字段第一个字符为 `c` 时表示字符设备；串口常见名称包括：

- `/dev/ttyUSB0`：常见 USB 转串口设备。
- `/dev/ttyACM0`：常见 USB CDC 设备，例如部分 STM32、Arduino。

以后真实设备接入后，常见权限形态为 `crw-rw---- root dialout ...`；此时用户需要属于 `dialout` 组才可直接访问。WSL 默认不会直接显示 Windows USB 设备，必须通过 `usbipd` 转发后才可能出现这些节点。

验证结果：`/dev/null`、`/dev/zero`、`/dev/random` 和 `/dev/tty` 均以 `c` 开头，确认它们是字符设备；中间的 `1, 3` 等数字为主设备号和次设备号。`/dev/null` 丢弃写入内容，`/dev/zero` 提供连续的零字节，`/dev/random` 提供随机数据，`/dev/tty` 指向当前控制终端。

`dialout:x:20:` 说明 `dialout` 组存在，但当前用户尚未加入；`/dev/ttyUSB0` 和 `/dev/ttyACM0` 不存在，说明 WSL 中尚无透传的串口设备。这些结果正常，暂不执行用户组修改。

## 16. Vim 最小操作（进行中）

Vim 在远程 SSH 机器、嵌入式 Linux 与救援环境中常见。初学阶段只需掌握以下最小流程：

1. `vim 文件名` 打开或创建文件。
2. 按 `i` 进入插入模式并编辑。
3. 按 `Esc` 回到普通模式。
4. 输入 `:wq` 后按回车，保存并退出。

常用退出补充：`:q!` 放弃未保存改动并退出；不要在 Vim 中用 `Ctrl+C` 代替保存或退出。

已完成练习：创建并保存 `vim_note.txt`，确认 `i`、`Esc`、`:wq` 的最小流程可用。

## 17. Shell 脚本参数与退出码（进行中）

脚本可通过 `$1` 读取第一个参数，通过 `$#` 读取参数数量。`exit 0` 表示成功；`exit 2` 常用于命令行参数错误。错误信息写入标准错误流的形式为 `>&2`。

`system_info.sh` 将增加：

- `--help`：显示简要用法并成功退出。
- 未知参数：显示错误并以状态码 `2` 退出。

`${1:-}` 表示“若第一个参数不存在，则使用空字符串”，可避免未传参数时读取变量出错。

已验证：`./system_info.sh --help` 显示用法并正常结束；`./system_info.sh --bad` 输出未知参数错误，随后 `$?` 为 `2`。

## 18. 项目 README（进行中）

公开 GitHub 仓库应包含 `README.md`，用于说明项目目的、环境、目录内容、运行命令和后续计划。对于机器人/嵌入式项目，README 应让读者快速判断：项目控制什么硬件、软件环境是什么、如何运行、当前验证到什么程度。

已创建 `README.md`：说明了 WSL/Ubuntu/VS Code 环境、`system_info.sh` 的用途与运行命令、当前学习主题和后续 C/C++、串口/CAN、嵌入式 Linux、ROS 2 的方向。Markdown 中的代码块以三个反引号开始和结束；遗漏结束标记会使后续内容错误显示为代码。

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

## 第二阶段：C/C++ 基础

### 1. C 程序、结构体与 GCC 编译

已创建第二阶段本地仓库：`~/linux_learning/stage2-c`，默认分支为 `main`。

已编写并验证 `main.c`。程序使用 `MotorState` 结构体保存一台电机的状态：

- `id`：电机编号
- `position_rad`：位置，单位为弧度
- `velocity_rad_s`：速度，单位为弧度每秒
- `temperature_c`：温度，单位为摄氏度
- `enabled`：是否使能

编译与运行命令：

```bash
gcc -std=c11 -Wall -Wextra -Wpedantic -g main.c -o motor_state
./motor_state
```
参数说明：`-std=c11` 指定 C11 标准；`-Wall -Wextra -Wpedantic` 开启更严格的编译警告；`-g` 生成后续 GDB 调试需要的调试信息；`-o motor_state` 指定生成的可执行文件名。

验证结果：程序成功输出电机编号、位置、速度、温度和使能状态。结构体可将同一台电机相关的数据组织在一起，之后读取编码器、CAN 电机反馈和控制器状态时会反复使用这种方式。

### 2. 基本类型、常量与电机速度单位换算

已编写并验证 `motor_units.c`，将电机转速从 rpm（每分钟转数）换算为 rad/s（弧度每秒）。

- `int` 用于电机编号等整数数据。
- `double` 用于速度、位置等带小数的物理量。
- `const double pi` 表示运行期间不应被修改的换算常量。

换算公式为 `rad/s = rpm × 2 × π / 60`。验证中 `60.00 rpm` 的结果为 `6.283 rad/s`。

编译、运行与提交：

```bash
gcc -std=c11 -Wall -Wextra -Wpedantic -g motor_units.c -o motor_units
./motor_units
git add motor_units.c .gitignore
git commit -m "Add motor unit conversion example"
```

已在 `stage2-c` 创建提交 `1e50609 Add motor unit conversion example`。编译产生的 `motor_state` 与 `motor_units` 已加入 `.gitignore`，不会误提交到 Git。

### 3. 多文件 C 工程、头文件与 Makefile

已在 `~/linux_learning/stage2-c/motor_monitor` 创建多文件电机状态示例：

```text
motor_monitor/
├── include/motor.h
├── src/main.c
├── src/motor.c
└── Makefile
```

- `motor.h` 声明 `MotorState` 和可供其他源文件调用的函数接口。
- `motor.c` 实现 `motor_print_status` 与 `motor_set_enabled`。
- `main.c` 创建状态数据并调用接口；传入 `&motor`，函数中以 `motor->字段` 访问结构体指针指向的数据。
- `Makefile` 用 `make` 自动编译各个 `.c` 文件为 `.o` 目标文件，再链接为 `motor_monitor` 可执行程序；配方命令行必须以 Tab 开头。

验证结果：`make` 成功编译 `src/main.c` 和 `src/motor.c`，随后链接生成程序。运行后先显示电机为 `enabled`，调用 `motor_set_enabled` 后显示为 `disabled`。

排错记录：`make: No rule to make target 'src/main.o'` 表示 Makefile 中写明的源文件路径不存在。检查发现 `motor.c` 和该项目的 `main.c` 被误放入 `include/`；将它们移动到 `src/` 后构建成功。`include/` 应存放头文件，`src/` 应存放源文件。

### 4. GDB 调试：空指针与调用栈

已安装 `gdb 15.1`。调试示例 `debug_null_motor.c` 模拟了电机状态数据尚未获得时误使用空指针的情况。

首次程序将 `MotorState *motor` 设为 `NULL`，随后传给 `motor_print_status`。使用以下流程定位问题：

```gdb
break motor_print_status
run
print motor
next
bt
quit
```

结果：断点处 `motor=0x0`，`print motor` 显示 `(const MotorState *) 0x0`。继续执行访问 `motor->id` 后收到 `SIGSEGV`；`bt` 显示调用链为 `main` 调用 `motor_print_status`，崩溃发生在后者访问结构体字段的位置。

修复方式：在 `main` 中创建有效的 `MotorState motor` 对象，并以 `&motor` 将其地址传给函数。重新编译和运行后输出 `Motor 3: 42.5 C`。

嵌入式/机器人程序中，设备未初始化、通信未成功或内存生命周期错误都可能形成空指针；出现崩溃时，优先用 GDB 的断点、`print` 和 `bt` 确认传入数据与调用链。

### 5. CMake：独立构建目录

已为 `motor_monitor` 创建 `CMakeLists.txt`，配置内容包括：C11 标准、`src/main.c` 和 `src/motor.c` 组成的可执行目标、`include/` 头文件搜索路径，以及 `-Wall -Wextra -Wpedantic` 编译警告选项。

构建流程：

```bash
cmake -S . -B build
cmake --build build
./build/motor_monitor
```

`-S .` 指定源码目录，`-B build` 指定独立的构建输出目录。CMake 首先生成适合当前环境的构建文件，随后由 `cmake --build` 驱动底层构建工具编译、链接。

验证结果：构建过程分别编译 `src/main.c` 与 `src/motor.c`，生成 `build/motor_monitor`；运行结果正确显示电机由 `enabled` 切换为 `disabled`。构建目录属于自动生成内容，后续应加入 `.gitignore`，不提交到 Git。

### 6. C++ 基础：用类封装电机状态

已创建 `cpp_motor_status.cpp`，使用 C++ 类 `Motor` 管理一台电机的编号、温度上限、位置、速度、温度和使能状态。

- 构造函数 `Motor(int id, double max_temperature_c)` 初始化必需配置；成员初始化列表以 `:` 开始。
- `private` 成员不能被类外代码直接修改，状态通过 `update_feedback` 等公开函数更新。
- `enable()` 在温度超过上限时返回 `false`，否则才把电机标记为已使能。
- `print_status() const` 表示该函数只读取对象状态；在硬件软件中，这有助于区分“查询”和“改变状态”的接口。

编译与运行：

```bash
g++ -std=c++17 -Wall -Wextra -Wpedantic -g cpp_motor_status.cpp -o cpp_motor_status
./cpp_motor_status
```

验证结果：输出电机的位置、速度、温度及 `enabled=true`。C++ 类适合组织驱动层对象、通信接口和控制器状态；后续仍需注意不在实时控制路径中滥用动态内存或异常机制。

### 7. C++ 多文件工程与 CMake

已创建独立项目 `~/linux_learning/stage2-c/cpp_motor_monitor`：

```text
cpp_motor_monitor/
├── include/motor.hpp
├── src/main.cpp
├── src/motor.cpp
└── CMakeLists.txt
```

- `motor.hpp` 只声明 `Motor` 类的构造函数、接口和私有成员。
- `motor.cpp` 包含头文件并以 `Motor::函数名` 实现成员函数。
- `main.cpp` 只依赖公开接口，创建电机对象、更新反馈、使能、打印状态并禁用。
- `CMakeLists.txt` 使用 `project(... LANGUAGES CXX)` 和 `CMAKE_CXX_STANDARD 17` 配置 C++17 构建。

构建命令：

```bash
cmake -S . -B build
cmake --build build
./build/cpp_motor_monitor
```

验证结果：CMake 分别编译 `src/main.cpp` 和 `src/motor.cpp`，生成并运行 `cpp_motor_monitor`。输出正确显示电机从 `enabled=true` 切换到 `enabled=false`。`build/` 是自动生成目录，应忽略而不提交。

### 8. C++ `enum class` 与电机故障状态

已将 C++ 电机类的布尔使能状态改为有限状态 `MotorMode`：`Disabled`、`Enabled`、`Fault`。

- `enum class` 是强类型枚举，使用时必须写明 `MotorMode::Fault` 等完整名称，避免把任意整数或无关枚举混入状态值。
- `update_feedback` 检测到温度超过上限时将状态置为 `Fault`。
- `enable()` 在故障或超温时返回 `false`，并保持/进入 `Fault`；只有安全状态才可进入 `Enabled`。
- `disable()` 不会清除故障，避免软件在未排查问题时误将故障电机重新视为正常。
- `motor_mode_to_string` 使用 `switch` 将枚举映射为日志友好的文字。

验证结果：40°C 时电机状态为 `enabled`；温度更新为 85°C（高于 80°C 上限）后状态为 `fault`，再次请求使能输出“拒绝在故障状态使能”。这类有限状态机是电机驱动、CAN 通信和安全互锁的基础。

### 9. CTest：电机状态机自动化测试

已将 `cpp_motor_monitor` 的构建配置调整为可复用的静态库与两个可执行文件：

- `motor_driver`：静态库，包含 `src/motor.cpp`。
- `cpp_motor_monitor`：演示程序，链接 `motor_driver`。
- `motor_test`：测试程序，链接同一份 `motor_driver`。

通过 `enable_testing()`、`add_test(NAME motor_test COMMAND motor_test)` 将测试注册给 CTest。测试覆盖三条规则：

1. 40°C 的安全电机可使能。
2. 85°C 的超温电机不可使能。
3. 已进入故障的电机即使温度恢复为 40°C，仍不可直接重新使能（故障锁存）。

构建和执行测试：

```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

验证结果：`motor_test` 通过，CTest 报告 `100% tests passed`。在实际机器人软件中，测试可在不连接真实电机的情况下持续验证安全逻辑，减少修改后引入回归错误的风险。

### 10. AddressSanitizer 与 UndefinedBehaviorSanitizer

Sanitizer 是编译时加入的运行时安全检查，通常在 WSL/PC 主机的调试和测试版本中使用：

- AddressSanitizer（ASan）可检测堆/栈数组越界、释放后访问等内存错误。
- UndefinedBehaviorSanitizer（UBSan）可检测多类未定义行为。
- `-fno-omit-frame-pointer` 让错误报告中的调用栈更易读。

练习 `sanitizer_demo.cpp` 创建了 3 个 `int` 的编码器数组，却故意读取 `encoder_counts[3]`。带 Sanitizer 的编译命令：

```bash
g++ -std=c++17 -Wall -Wextra -Wpedantic -g \
  -fsanitize=address,undefined -fno-omit-frame-pointer \
  sanitizer_demo.cpp -o sanitizer_demo
```

运行报告 `heap-buffer-overflow`，定位到 `sanitizer_demo.cpp:7`。报告说明数组分配区域为 12 字节（3 个 4 字节 `int`），访问位置刚好在该区域之后。将索引改为合法的 `encoder_counts[2]` 后，程序正常输出 `Latest encoder count: 110`，不再报告错误。

Sanitizer 会带来额外内存和运行开销，通常不直接部署到资源受限的单片机固件；但在主机端先运行它，可提前发现未来在设备端难以复现的内存问题。

### 11. C++ RAII：管理 Linux 设备文件描述符

已编写 `file_descriptor_demo.cpp`，使用 C++ 类 `FileDescriptor` 管理 Linux 文件描述符。示例安全地以只读方式打开 `/dev/null`，为后续打开串口设备（如 `/dev/ttyUSB0`）或其他设备接口建立资源管理模式。

- 构造函数调用 POSIX `open`；若失败，抛出包含 `strerror(errno)` 系统错误信息的异常。
- 析构函数调用 `close`。对象离开作用域时，C++ 自动执行析构函数，因此即使中间函数提前返回或发生异常，也不会遗漏关闭资源。
- 拷贝构造和拷贝赋值被 `= delete` 禁用，避免两个对象持有同一个文件描述符并重复 `close`。
- `get() const noexcept` 只读返回底层文件描述符；`const` 表示不改变对象，`noexcept` 表示该函数不会抛出异常。

验证结果：程序输出 `Opened /dev/null, fd=3`。文件描述符 0、1、2 通常分别是标准输入、标准输出和标准错误，因此新打开的第一个文件经常是 3。之后将把相同结构用于串口和 CAN 接口。

### 12. Linux 串口基础：`termios` 与伪终端

已编写 `serial_termios_demo.cpp`。程序通过 `openpty` 创建一对伪终端（master/slave），将 slave 端当作串口设备，并以 `termios` 将其配置为 115200、8N1、无软件流控、非规范（原始）模式。伪终端使得没有真实硬件时也可验证串口配置代码。

关键配置：

- `cfsetispeed` / `cfsetospeed`：设置输入和输出波特率为 `B115200`。
- `~PARENB`：关闭校验位；`~CSTOPB`：使用 1 个停止位；`CS8`：使用 8 个数据位，即 8N1。
- `CREAD`：启用接收；`CLOCAL`：忽略调制解调器控制线，常用于 USB 转串口设备。
- 关闭 `ICANON`、回显和软件流控，避免终端按行缓冲或解释控制字符。
- `VMIN=0`、`VTIME=10`：读取可立即返回；如无数据，最多等待约 1 秒。

编译时 `openpty` 需要链接 `libutil`：

```bash
g++ -std=c++17 -Wall -Wextra -Wpedantic -g \
  serial_termios_demo.cpp -o serial_termios_demo -lutil
```

验证结果：成功配置伪串口 `/dev/pts/14`（编号会变化）并输出 `Configured pseudo serial port ... at 115200 8N1.`。未来真实设备透传到 WSL 后，设备路径将通常是 `/dev/ttyUSB0` 或 `/dev/ttyACM0`；打开设备、调用 `tcgetattr`、修改配置、调用 `tcsetattr` 的流程相同。

### 13. 电机文本协议帧解析与 `std::optional`

已编写 `motor_protocol.cpp`，将模拟电机控制器反馈帧：

```text
MOTOR,1,1.25,6.28,36.8
```

解析为 `MotorFeedback` 结构体中的电机编号、位置、速度和温度。

- `std::istringstream` 与 `std::getline(..., ',')` 按逗号分割文本帧。
- 帧字段数不足或首字段不为 `MOTOR` 时返回 `std::nullopt`。
- `std::stoi` / `std::stod` 的转换异常被捕获后也返回 `std::nullopt`。
- `std::optional<MotorFeedback>` 明确表达“可能解析成功，也可能没有有效数据”，避免用魔法数或未初始化数据代替错误状态。

使用 C++17 编译时，最初的 `.id = ...` 指定初始化器触发了 C++20 扩展警告。该项目使用 C++17，因此改为按结构体字段顺序的聚合初始化：

```cpp
return MotorFeedback{
    std::stoi(id_text),
    std::stod(position_text),
    std::stod(velocity_text),
    std::stod(temperature_text)
};
```

修复后使用 `-std=c++17 -Wall -Wextra -Wpedantic` 编译无警告，程序正确输出 `Motor 1 | pos=1.25 rad | vel=6.28 rad/s | temp=36.80 C`。后续将把真实串口读取到的一行数据交给同一解析函数。

### 14. 伪串口回环：读取并解析电机反馈

已将协议解析器拆分为接口与实现：

- `motor_protocol.hpp`：声明 `MotorFeedback` 和 `parse_motor_feedback`。
- `motor_protocol.cpp`：实现解析逻辑，不再包含 `main`。
- `serial_loopback_demo.cpp`：创建伪终端、模拟控制器发送、模拟主机读取，并调用解析器。

伪串口回环流程：

1. `openpty` 创建 controller（master）和 host（slave）两端。
2. host 端用 `cfmakeraw`、`B115200`、`CLOCAL | CREAD` 配置为原始串口模式。
3. controller 端写入 `MOTOR,1,1.25,6.28,36.8\n`。
4. host 端以 `read` 读取字节，移除结尾 `\n` / `\r`。
5. 将完整文本帧交给 `parse_motor_feedback`，得到类型安全的 `MotorFeedback` 数据。

编译时将主程序与解析器一同编译，且 `openpty` 需要 `-lutil`：

```bash
g++ -std=c++17 -Wall -Wextra -Wpedantic -g \
  serial_loopback_demo.cpp motor_protocol.cpp \
  -o serial_loopback_demo -lutil
```

验证结果：程序从伪串口 `/dev/pts/14`（编号会变化）读取并输出 `motor=1`、位置 `1.25 rad`、速度 `6.28 rad/s`、温度 `36.80 C`。真实串口接入后，通常只需将伪终端替换为 `/dev/ttyUSB0` 或 `/dev/ttyACM0`，而读取、协议解析和上层状态处理可复用。

### 15. 串口帧读取：`poll`、超时与分段数据

真实串口的单次 `read()` 不保证刚好得到完整一帧；数据可能被拆分、合并或延迟到达。已编写 `serial_frame_reader_demo.cpp`，使用 `poll()` 和逐字节缓冲解决该问题。

- 控制器端故意分两次发送：`MOTOR,1,1.25,` 与 `6.28,36.8\n`。
- `read_line(fd, 1000)` 使用 `poll` 等待输入事件；若连续 1 秒没有下一个字节，则报超时并返回空值。
- 每次只读取一个字节；遇到 `\n` 才返回完整帧，忽略 `\r`，并限制最大帧长为 256 字节。
- 返回 `std::optional<std::string>`，明确区分完整帧、超时/读取错误和超长帧。

构建命令：

```bash
g++ -std=c++17 -Wall -Wextra -Wpedantic -g \
  serial_frame_reader_demo.cpp motor_protocol.cpp \
  -o serial_frame_reader_demo -lutil
```

验证结果：尽管帧被拆分发送，程序仍输出 `Received complete frame ... motor=1 ...`。真实电机控制器通信中应始终采用类似的缓冲与帧边界策略，不能假设一次 `read` 对应一条消息。

### 16. SocketCAN 帧格式：CAN ID、DLC 与字节序

已编写 `can_frame_demo.cpp`，直接使用 Linux `<linux/can.h>` 中的 `struct can_frame` 在内存中构造和解析 CAN 帧；本节不向任何真实总线发送数据。

示例定义：

- 标准 CAN ID：`0x201`。
- 数据长度 `len`（DLC）：8 字节。
- 示例协议将目标电流 `1500 mA` 存在前两个数据字节，采用大端序，因此编码为 `0x05 0xdc`。

编码时先将有符号 `int16_t` 转为无符号 `uint16_t` 保留其二进制位，再取高字节、低字节；解码时把两个字节合成为 `uint16_t`，最后转回 `int16_t`。

构建与验证：

```bash
g++ -std=c++17 -Wall -Wextra -Wpedantic -g \
  can_frame_demo.cpp -o can_frame_demo
./can_frame_demo
```

程序输出 CAN ID `0x201`、8 字节数据 `0x05 0xdc 0x00 ...`，并正确还原 `Decoded current: 1500 mA`。真实电机协议的 CAN ID、字节序、缩放比例、符号位和校验方式必须以厂商协议文档为准；未确认协议时绝不能向真实电机发送命令。
