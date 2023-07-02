# 基础镜像
FROM ubuntu:latest
# 作者
MAINTAINER godev-ubuntu
# 换阿里云源,安装openssh,修改配置文件,生成key,同步时间
RUN echo "deb http://mirrors.163.com/ubuntu/ focal main restricted universe multiverse\n \
deb http://mirrors.163.com/ubuntu/ focal-security main restricted universe multiverse \n \
deb http://mirrors.163.com/ubuntu/ focal-updates main restricted universe multiverse\n	\
deb http://mirrors.163.com/ubuntu/ focal-backports main restricted universe multiverse\n"\
            > /etc/apt/sources.list        \
            && apt update && apt install -y openssh-server && apt clean \
		&& echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
            && echo 'root:admin123456' |chpasswd && mkdir -p /var/run/sshd
# 下载和解压
RUN wget -P /root  https://golang.google.cn/dl/go1.20.4.linux-amd64.tar.gz && tar -C /usr/local -xzf /root/go1.20.4.linux-amd64.tar.gz
# 环境变量
ENV PATH $PATH:/usr/local/go/bin
ENV GOPROXY https://goproxy.cn,direct
ENV GO111MODULE on
# 使用bash
SHELL ["bash","-c"]
# 写入环境变量文件
RUN echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile && source /etc/profile
# 暴露8080端口
EXPOSE 8080
# 暴露端口
EXPOSE 22
# 复制脚本文件
COPY start.sh /root/
# 授权执行
RUN  chmod +x /root/start.sh
# 工作文件夹
WORKDIR /root
# 容器启动时执行ssh启动命令
ENTRYPOINT ./start.sh
