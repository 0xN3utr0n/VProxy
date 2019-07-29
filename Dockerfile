FROM debian:latest
MAINTAINER 0xN3utron <0xn3utr0n@pm.com>

RUN apt update && apt -y install openvpn ssh net-tools iptables tor curl

COPY cnf/vpn /root/vpn
COPY cnf/sshd_config /etc/ssh/sshd_config
RUN adduser --disabled-password --gecos '' user

USER user
RUN mkdir -p /home/user/.ssh
RUN ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
RUN cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
RUN chmod 600 ~/.ssh/id_rsa*

USER root
COPY ./src/startup.sh /opt/startup.sh
ENTRYPOINT ["/bin/bash", "/opt/startup.sh"]
