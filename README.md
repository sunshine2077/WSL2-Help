# 一.wsl1和wsl2

wsl1无完整的linux内核，使用Windows NT kernel来模拟实现linux环境，将Linux系统调用转化为Win系统调用，本质为模拟器

wsl2提供完整的linux内核，通过VM虚拟化技术运行linux环境，本质为虚拟机

wsl2的优势：使用方便；与win完全融合，交互便捷；轻量化，启动速度快

# 二.安装与配置

## 1.wsl2安装

保证BIOS中开启虚拟化技术[大部分计算机默认开启，可在Windows任务管理器/CPU界面查看是否开启虚拟化]

控制面板/程序/启动或关闭Windwos功能：虚拟机平台，适用于Windwos的Linux子系统

重启计算机

## 2.系统安装

### (1)官方发行版手动安装

应用商店下载对应的发行版并打开安装

### (2)官方发行版命令安装

```powershell
# 查看所有的官方发行版名称
wsl  --list --online
# 安装官方发行版
wsl install -d 发行版名称
```

### (3)第三方发行版

自行下载，完成后双击安装：[Releases · mishamosher/CentOS-WSL (github.com)](https://github.com/mishamosher/CentOS-WSL/releases)

## 3.系统迁移

系统迁移到D盘：

```powershell
# 导出镜像
wsl --export 发行版名称 导出文件位置\导出文件名.tar
# 注销原有系统
wsl --unregister 发行版名称
# 从tar镜像中导出虚拟硬盘，方便使用（之后对WSL2系统的文件操作再虚拟硬盘中进行，镜像不再更新，除非导出新镜像）
wsl --import 发行版名称 导出文件位置 导出文件位置\导出文件名.tar
# 恢复默认用户
发行版名称 config --default-user 默认用户名
```

## 4.设置Bridge网络模式
(1)家庭版需要先安装hyper-v，执行以下bat命令并重启计算机：
```bat
pushd "%~dp0"
dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyper-v.txt
for /f %%i in ('findstr /i . hyper-v.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"
del hyper-v.txt
Dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /LimitAccess /ALL
```
(2)创建虚拟交换机
用powershell创建虚拟交换机：New-VMSwitch "虚拟交换机名称" -NetAdapterInterfaceDescription "网络适配器名称" 
```powershell
New-VMSwitch "wsl2Network" -NetAdapterInterfaceDescription "Remote NDIS based Internet Sharing Device"
```
(3)设置wslconfig
用powershell执行`cd ~`，用notepad创建`.wslconfig`文件，写入以下内容
```ini
[wsl2]
# 使用桥接网络
networkingMode=bridged
# 刚刚创建的虚拟交换机
vmSwitch=wsl2Network
# 开启ipv6
ipv6=true
```
(4) 打开wsl2终端，输入`ifconfig`查看eth0是否拥有ipv6地址（fe80开头的是本地地址,非fe80开头的才是公网IP）,可通过`https://ipw.cn/ipv6webcheck/`输入ipv6地址测试连通性
若不连通可能由于Windows防火墙拦截，可临时关闭防火墙测试

## 5.docker
(1) 打开powershell
```shell
#  更新wsl
wsl --update
# 保证启用wsl2:报错可尝试先wsl --set-version 发行版名称 1，再wsl --set-version 发行版名称 2
wsl --set-version 发行版名称 2
```
(2) 打开linuxshell，更新apt并开启systemd
```shell
# 更新apt
sudo apt update
sudo apt-get update
sudo apt upgrade
# 启动systemd
sudo vim /etc/wsl.conf
```
(3) 填入以下内容开启systemd
```ini
#允许systemd
[boot]
systemd=true
```
(4) 下载和安装
```shell
# 方法(1)官方脚本安装
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# 方法(2)apt安装
sudo apt install docker.io
# 启动docker
sudo systemctl start docker
# 查看docker状态
sudo systemctl status docker
```

(5) 安装nvidia-docker
```shell
# 查看nvidia GPU驱动，若无显示则更新Windows显卡驱动和wsl2版本为最新
nvidia-smi
# 安装cuda套件
sudo apt install nvidia-cuda-toolkit
# 查看cuda版本
sudo nvcc --version
# 获取nvidia-docker源
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
# 更新源
sudo apt update
# 安装nvidia-docker
sudo apt-get install -y nvidia-docker2
# 若报/usr/lib/wsl/lib/libcuda.so.1 is not a symbolic link则修复软连接
cd /usr/lib/wsl
sudo mkdir lib2
sudo ln -s lib/* lib2
sudo vim /etc/ld.so.conf.d/ld.wsl.conf
# 将 /usr/lib/wsl/lib 改为 /usr/lib/wsl/lib2
sudo vim /etc/wsl.conf
# 添加以下项
[automount]
ldconfig = fasle
# 重启docker
sudo systemctl restart docker
```

## 6.额外系统配置

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

## 7.注意事项

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




# 五.实践

## 配置python开发环境

### (1)dockerfile

复制dockerfile到linux发行版目录，执行如下操作构建镜像：
```shell
sudo docker build -t ubuntu:python .
```

### (2)启动镜像实例
```shell
sudo docker run -d --name python-dev -p 12888:22 -p 12580:8080 -v /home/docker/pythondev:/root ubuntu:python
```

### (3)ssh登录
打开powershell
```powershell
# 客户端本地生成一对公私钥，直接回车
ssh-keygen -t rsa
# 发送公钥给服务器
function ssh-copy-id([string]$userAtMachine, $args){   
    $publicKey = "$ENV:USERPROFILE" + "/.ssh/id_rsa.pub"
    if (!(Test-Path "$publicKey")){
        Write-Error "ERROR: failed to open ID file '$publicKey': No such file"            
    }
    else {
        & cat "$publicKey" | ssh $args $userAtMachine "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys || exit 1"      
    }
}
ssh-copy-id 用户名@ip地址
输入密码
# ssh登录
ssh 用户名@ip地址
# 服务端检查客户端公钥信息
cat /.ssh/authorized_keys
```



