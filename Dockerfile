FROM debian:stable

ENV TERM=xterm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -yqq --no-install-recommends install samba acl attr quota fam winbind libpam-winbind \
libpam-krb5 libnss-winbind krb5-config krb5-user ntp dnsutils ldb-tools supervisor smbclient samba-vfs-modules

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN env --unset=DEBIAN_FRONTEND

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /entrypoint.sh

EXPOSE 137 138 139 445

HEALTHCHECK --interval=60s --timeout=15s \
            CMD smbclient -L \\localhost -U % -m SMB3

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
