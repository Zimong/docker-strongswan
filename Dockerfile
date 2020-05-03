FROM ubuntu:16.04
ENV TZ=Asia/Shanghai
COPY *.sh /
RUN chmod a+x /*.sh && /deploy.sh && \
    mv /etc/ipsec.conf /etc/ipsec.secrets /etc/strongswan.conf /etc/ipsec.d/ && \
    ln -sf /etc/ipsec.d/ipsec.conf /etc/ipsec.d/ipsec.secrets /etc/ipsec.d/strongswan.conf /etc/
EXPOSE 500/udp 4500/udp
CMD [ "/boot.sh" ]

