# 基础镜像
FROM ubuntu
# 作者
MAINTAINER sunshine2077
# 工作目录
WORKDIR /root
# 用bash
SHELL ["bash","-c"]
# 加包
RUN apt update 				&&					\
    apt upgrade -y 			&&					\	 
    apt install -y build-essential 	&&   					\
    apt install -y git 			&&               			\
    apt install -y openssh-server 	&&    					\
    apt clean 				&& 					\
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config &&			\
    echo 'root:admin123456' |chpasswd && 					\
    mkdir -p /var/run/sshd	      &&					\
    wget -P /root  https://golang.google.cn/dl/go1.20.4.linux-amd64.tar.gz &&   \
    tar -C /usr/local -xzf /root/go1.20.4.linux-amd64.tar.gz &&			\
    echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile && 		\
    source /etc/profile
# 环境变量
ENV PATH=$PATH:/usr/local/go/bin GOPROXY=https://goproxy.cn,direct  GO111MODULE=on
# 暴露22，80，443端口
EXPOSE 22 80 443
# 启动时执行命令
ENTRYPOINT echo "开启SSHD" && /usr/sbin/sshd -D
