FROM ubuntu:focal AS builder

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -yqq --no-install-recommends install acl attr quota fam \
 ntp dnsutils ldb-tools supervisor smbclient \
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
    tar \
    tree \
    uuid-dev \
    wget \
    xfslibs-dev \
    xsltproc \
    zlib1g-dev

RUN wget https://download.samba.org/pub/samba/stable/samba-4.17.0.tar.gz

RUN tar -zxf samba-4.17.0.tar.gz

WORKDIR /samba-4.17.0

RUN ./configure

RUN make

RUN sed '1s@^.*$@#!/usr/bin/python3@' -i ./bin/default/source4/scripting/bin/samba-gpupdate.inst

RUN make install

ENV PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH

WORKDIR /

RUN rm -rf /samba-4.17.0

RUN mv -v /usr/local/samba/lib/libnss_win{s,bind}.so.*  /lib

RUN ln -v -sf ../../lib/libnss_winbind.so.2 /usr/local/samba/lib/libnss_winbind.so

RUN ln -v -sf ../../lib/libnss_wins.so.2    /usr/local/samba/lib/libnss_wins.so

COPY entrypoint.sh /entrypoint.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /entrypoint.sh

RUN tar -cf artifacts.tar /usr/local/ /etc/samba/ /entrypoint.sh /etc/supervisor/conf.d/supervisord.conf /lib/libnss_win{s,bind}.so.*

FROM ubuntu:focal

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

COPY --from=builder /artifacts.tar /artifacts.tar

RUN apt -y update && apt -y upgrade && \
    apt -yqq --no-install-recommends install acl attr \
	ntp dnsutils ldb-tools supervisor \
	libbsd-dev libpopt-dev libreadline-dev libcap-dev libicu-dev libunwind-dev libjansson-dev liblmdb-dev libgpgme11-dev libarchive-dev \
	libdbus-1-3 libexpat1 libgssapi-krb5-2 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldb2 libmpdec2 libpython3-stdlib libpython3.8  libpython3.8-minimal libpython3.8-stdlib libssl1.1 libtalloc2 libtdb1 libtevent0 libwbclient0 mime-support python3 python3-crypto python3-dnspython python3-ldb python3-minimal python3-samba python3-talloc  python3-tdb python3.8 python3.8-minimal tdb-tools ucf  \
	&& rm -rf /var/lib/apt/lists/* \
	&& tar -xf /artifacts.tar \
	&& rm -rf /artifacts.tar

ENV PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH

RUN ldconfig

EXPOSE 137 138 139 445

HEALTHCHECK --interval=60s --timeout=15s \
            CMD smbclient -L \\localhost -U % -m SMB3

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]