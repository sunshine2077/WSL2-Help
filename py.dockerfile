# 基础镜像
FROM ubuntu:latest
# 作者
MAINTAINER pydev-ubuntu
# 换阿里云源,安装openssh,修改配置文件,生成key,同步时间
RUN echo "deb http://mirrors.163.com/ubuntu/ focal main restricted universe multiverse\n \
deb http://mirrors.163.com/ubuntu/ focal-security main restricted universe multiverse \n \
deb http://mirrors.163.com/ubuntu/ focal-updates main restricted universe multiverse\n	\
deb http://mirrors.163.com/ubuntu/ focal-backports main restricted universe multiverse\n"\
            > /etc/apt/sources.list        \
            && apt update && apt install -y openssh-server && apt install -y python3-pip && apt clean \
		&& echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
            && echo 'root:admin123456' |chpasswd && mkdir -p /var/run/sshd
# 暴露8080端口
EXPOSE 8080
# 暴露端口
EXPOSE 22
# 容器启动时执行ssh启动命令
ENTRYPOINT echo "开启SSHD" && /usr/sbin/sshd -D
