# 一.wsl1和wsl2

wsl1无完整的linux内核，使用Windows NT kernel来模拟实现linux环境，本质为模拟器

wsl2提供完整的linux内核，通过VM虚拟化技术运行linux环境，本质为虚拟机

wsl2的优势：使用方便；与win完全融合，交互便捷；轻量化，启动速度快

# 二.安装与配置

## 1.wsl2安装

保证BIOS中开启虚拟化技术

控制面板/程序/启动或关闭Windwos功能：虚拟机平台，适用于Windwos的Linux子系统

## 2.系统安装

### (1)官方发行版

应用商店下载ubuntu并打开安装

### (2)第三方发行版

自行下载，完成后双击安装：[Releases · mishamosher/CentOS-WSL (github.com)](https://github.com/mishamosher/CentOS-WSL/releases)

## 3.系统配置

### (1)wsl.conf

wsl.conf路径为wsl2下的/etc/wsl.conf，没有可以手动创建，是每一个发行版的具体配置

```properties
# 自动挂载设定
[automount]
# 自动挂载win驱动器(c:,d:,e:等)
enabled = true
# 挂载硬盘的路径
root = /mnt/
# 自动挂载/etc/fstab的文件系统
mountFsTab = true
# 自动挂载文件系统的访问权限设置
options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off"

# 网络设定
[network]
# 主机名
hostname = DemoHost
# 自动生成/etc/hosts文件
generateHosts = false
# 自动生成/etc/resolv.conf文件
generateResolvConf = false

# win与wsl2交互设定
[interop]
# 允许启动win进程
enabled = true
# 添加$PATH环境变量
appendWindowsPath = true

# 用户设定
[user]
# 首次启动默认创建的用户名
default = DemoUser

# 启动设定
[boot]
# 开启systemctl,[默认关闭]
systemd = true
# 期望wsl2启动时运行的命令
command = sudo systemctl start docker
```

### (2).wslconfig

路径为win下的`%UserProfile%/.wslconfig` ，所有已安装发行版的全局配置

```properties
# wsl2全局配置
[wsl2]
# 分配内存大小
memory=4GB 
# 逻辑处理器数量
processors=2
# 自定义内核路径
kernel=C:\\temp\\myCustomKernel
# 设置额外的内核参数
kernelCommandLine = vsyscall=emulate
# 超出分配内存大小后允许与win交换内存的大小
swap=8GB
# wsl2实际物理信息存储路径
swapfile=C:\\temp\\wsl-swap.vhdx
# 允许win回收分配给wsl2的未使用内存
pageReporting=true
# 允许wsl2的localhost与win的localhost绑定
localhostforwarding=true
# 允许wsl2内部进行套娃虚拟化
nestedVirtualization=true
# 开启debug黑窗口
debugConsole=true
# 开启wsl2的GUI支持
guiApplications=false
```

## 4.docker

```shell
# 更新apt
sudo apt update
sudo apt-get update
sudo apt upgrade
# 安装docker
sudo apt install docker-ce docker-ce-cli containerd.io
# 启动docker
sudo service docker start
# 查看docker状态
sudo service docker status
```

## 5.注意事项

存在之前的发行版未删除干净可能导致安装失败，ps执行`wsl --unregister 发行版名称`注销该发行版

安装失败的另一个原因可能是默认的wsl版本较老，ps执行`wsl --update`更新wsl版本

wsl2支持安装多个发行版，ps执行`wsl -list`可查看各个发行版的信息，用`wsl --setdefault 发行版名称`可设置默认发行版名称

# 三.基本ps命令

```powershell
# 使用wsl2前需要先更新wsl版本
wsl --update
# 查询wsl版本
wsl --version
# 查询wsl状态
wsl --status
# 查询已经安装的所有发行版
wsl --list
# 设置默认发行版
wsl --set-default 发行版名称
# 特定用户打开wsl
wsl --user 用户名
# 强制关闭wsl
wsl --shutdown
# 强制关闭某个发行版
wsl --terminate 发行版名称
# 弃用某个发行版时需要注销，否则影响后续安装
wsl --unregister 发行版名称
# 运行某个发行版
wsl --distribution 发行版名称 --user 用户名
# 导出发行版
wsl --export 发行版名称 文件名
# 导入发行版
wsl --import 发行版名称 安装位置 文件名
# 挂载硬盘
wsl --mount 硬盘地址
# 取消挂载硬盘
wsl --unmount 硬盘地址
```

# 四.交互

## 1.文件交互

### (1)wsl2可通过`\mnt\*`访问win文件

挂载后给win默认添加四个元数据：\$LXUID(用户所有者ID),\$LXGID(组所有者ID),\$LXMOD(文件权限),\$LXDEV(设备)

可通过wsl.conf配置访问权限，访问时若存在元数据，则使用元数据信息，否则将win文件权限映射为对应linux权限

### (2)win可通过`\\wsl$\发行版名称`访问wsl2文件

默认与发行版默认用户相同权限

### (3)注意

**瞎几把用sudo rm rf /*有可能删除win宿主机文件，甚至破坏win系统，避免该操作**

**win文件系统下不区分大小写，linux文件系统下区分大小写**

**跨文件系统操作可能导致I/O缓慢**

## 2.命令交互

原理：共享环境变量

wsl2下可访问win下的环境变量**$PATH**

wsl2和win共享环境变量**$WSLENV**

### (1)wsl2下可用`命令名.exe`调用win下的命令：

| 命令样例           | 操作                              |
| ------------------ | --------------------------------- |
| explorer.exe .     | 调用win文件管理器查看wsl2文件内容 |
| notepad.exe 文件名 | 调用win记事本编辑器查看文件       |
| powershell.exe     | 调用ps在当前目录                  |

### (2)win下可用`wsl 命令内容`调用wsl2下的命令：

| 命令样例           | 操作                        |
| ------------------ | --------------------------- |
| wsl ls -a          | 调用wsl命令查看当前文件列表 |
| wsl touch data.txt | 调用wsl命令创建文件         |
| wsl mkdir test     | 调用wsl命令创建文件夹       |

### (3)win下混合wsl2命令：

| 命令样例                          | 操作                                              |
| --------------------------------- | ------------------------------------------------- |
| wsl ls -la findstr "git"          | 调用wsl2命令将列出当前目录文件并查找名未git的内容 |
| wsl ls -la > out.txt              | 调用wsl2命令将当前目录文件重定向到out.txt         |
| wsl ls -la "/mnt/c/Program Files" | 调用wsl2命令列出win下“c/Program Files”的所有文件  |
| dir wsl grep git                  | 列出当前目录并调用wsl2的查询命令查找              |

### (4)wsl2下混合win命令：

| 命令样例                                    | 操作                                            |
| ------------------------------------------- | ----------------------------------------------- |
| ipconfig.exe \| grep -a IPv4 \| cut -d: -f2 | 调用win命令列出ip配置并查询名为IPV4的信息并截取 |
| ls -la findstr.exe test.txt                 | 列出当前目录并调用win命令查询                   |

## 3.网络交互
### (1)win访问wsl2
wsl2和win共享localhost(127.0.0.1)，win可通过localhost或wsl2的eth0的IP来访问wsl2服务
### (2)wsl2访问win
1.ipconfig.exe查看win下wsl2的外部通讯网卡，ifconfig查看wsl2的eth0的虚拟网卡，两者应当在`同一网段(IP地址与子网掩码值应相同)`内
2.Windows Defender防火墙默认拦截wsl2访问win，管理员打开powershell添加Windows防火墙规则
```powershell
# 允许WSL通过防火墙
New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow
# 禁止WSL通过防火墙
New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Block
```
### (3)远程访问wsl2

### (4)wsl2访问远程
通过eth0 IP访问局域网其他设备，若访问公网则经过NAT转为公网IP直接访问

### (5)wsl2使用vpn
7890为vpn代理程序的端口号
先获取host_ip为wsl2与外界通讯的IP
再设置all_procy（https_proxy和http_proxy的合并）
```shell
export hostip=$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')
export all_proxy="http://${hostip}:7890"
```
