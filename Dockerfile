FROM ubuntu:latest

ENV TERM=xterm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -yqq --no-install-recommends install acl attr quota fam libpam-winbind \
libpam-krb5 libnss-winbind krb5-config krb5-user ntp dnsutils ldb-tools supervisor smbclient samba-vfs-modules\
    acl \
    apt-utils \
    attr \
    autoconf \
    bind9utils \
    binutils \
    bison \
    build-essential \
    ccache \
    chrpath \
    curl \
    debhelper \
    dnsutils \
    docbook-xml \
    docbook-xsl \
    flex \
    gcc \
    gdb \
    git \
    glusterfs-common \
    gzip \
    heimdal-multidev \
    hostname \
    htop \
    krb5-config \
    krb5-kdc \
    krb5-user \
    language-pack-en \
    lcov \
    libacl1-dev \
    libarchive-dev \
    libattr1-dev \
    libavahi-common-dev \
    libblkid-dev \
    libbsd-dev \
    libcap-dev \
    libcephfs-dev \
    libcups2-dev \
    libdbus-1-dev \
    libglib2.0-dev \
    libgnutls28-dev \
    libgpgme11-dev \
    libicu-dev \
    libjansson-dev \
    libjs-jquery \
    libjson-perl \
    libkrb5-dev \
    libldap2-dev \
    liblmdb-dev \
    libncurses5-dev \
    libpam0g-dev \
    libparse-yapp-perl \
    libpcap-dev \
    libpopt-dev \
    libreadline-dev \
    libsystemd-dev \
    libtasn1-bin \
    libtasn1-dev \
    libtracker-sparql-2.0-dev \
    libunwind-dev \
    lmdb-utils \
    locales \
    lsb-release \
    make \
    mawk \
    mingw-w64 \
    patch \
    perl \
    perl-modules \
    pkg-config \
    procps \
    psmisc \
    python3 \
    python3-cryptography \
    python3-dbg \
    python3-dev \
    python3-dnspython \
    python3-gpg \
    python3-iso8601 \
    python3-markdown \
    python3-matplotlib \
    python3-pexpect \
    python3-pyasn1 \
    python3-setproctitle \
    rng-tools \
    rsync \
    sed \
    sudo \
    tar \
    tree \
    uuid-dev \
    wget \
    xfslibs-dev \
    xsltproc \
    zlib1g-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN env --unset=DEBIAN_FRONTEND

RUN wget https://download.samba.org/pub/samba/stable/samba-4.15.0.tar.gz

RUN tar -zxf samba-4.15.0.tar.gz

RUN wget https://gitlab.com/samba-team/samba/-/merge_requests/1908.patch -O /tmp/patch.txt

WORKDIR /samba-4.15.0

RUN patch -p 1 < /tmp/patch.txt

RUN ./configure

RUN make

RUN make install

ENV PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /entrypoint.sh

EXPOSE 137 138 139 445

HEALTHCHECK --interval=60s --timeout=15s \
            CMD smbclient -L \\localhost -U % -m SMB3

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
