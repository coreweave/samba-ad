FROM ubuntu:latest

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

RUN wget https://download.samba.org/pub/samba/stable/samba-4.15.0.tar.gz

RUN tar -zxf samba-4.15.0.tar.gz

RUN wget https://gitlab.com/samba-team/samba/-/merge_requests/1908.patch -O /tmp/patch.txt

WORKDIR /samba-4.15.0

RUN patch -p 1 < /tmp/patch.txt

RUN ./configure

RUN make

RUN sed '1s@^.*$@#!/usr/bin/python3@' -i ./bin/default/source4/scripting/bin/samba-gpupdate.inst

RUN make install

ENV PATH=/usr/local/samba/bin/:/usr/local/samba/sbin/:$PATH

WORKDIR /

RUN rm -rf /samba-4.15.0

RUN mv -v /usr/local/samba/lib/libnss_win{s,bind}.so.*  /lib

RUN ln -v -sf ../../lib/libnss_winbind.so.2 /usr/local/samba/lib/libnss_winbind.so

RUN ln -v -sf ../../lib/libnss_wins.so.2    /usr/local/samba/lib/libnss_wins.so

RUN ldconfig

ENV SUDO_FORCE_REMOVE=yes

RUN apt remove -yqq apt-utils autoconf automake autopoint autotools-dev bind9-dnsutils bind9-host bind9-libs bind9-utils bind9utils binutils binutils-common binutils-mingw-w64-i686 binutils-mingw-w64-x86-64 binutils-x86-64-linux-gnu bison bsdmainutils build-essential ca-certificates ccache chrpath comerr-dev cpp cpp-9 curl dbus-user-session dconf-gsettings-backend dconf-service debhelper dh-autoreconf dh-strip-nondeterminism distro-info-data dnsutils docbook-xml docbook-xsl dpkg-dev dwz fam flex fonts-lyx g++ g++-9 g++-mingw-w64 g++-mingw-w64-i686 g++-mingw-w64-x86-64 gcc gcc-9 gcc-9-base gcc-mingw-w64 gcc-mingw-w64-base gcc-mingw-w64-i686 gcc-mingw-w64-x86-64 gdb gettext gettext-base gir1.2-glib-2.0 gir1.2-tracker-2.0 git git-man glib-networking glib-networking-common glib-networking-services glusterfs-common groff-base gsettings-desktop-schemas heimdal-multidev htop icu-devtools intltool-debian krb5-config krb5-kdc krb5-multidev krb5-user language-pack-en language-pack-en-base lcov ldb-tools libacl1-dev libaio1 libarchive-dev libarchive-zip-perl libarchive13 libargon2-1 libasan5 libassuan-dev libatomic1 libattr1-dev libavahi-common-dev libbabeltrace1 libbinutils libblas3 libblkid-dev libbrotli1 libbsd-dev libc-dev-bin libc6-dev libcap-dev libcc1-0 libcephfs-dev libcroco3 libcrypt-dev libcryptsetup12 libctf-nobfd0 libctf0 libcups2-dev libcupsimage2 libcupsimage2-dev libcurl3-gnutls libcurl4 libdbus-1-dev libdconf1 libdebhelper-perl libdevmapper1.02.1 libdpkg-perl libdw1 libedit2 libelf1 liberror-perl libevent-2.1-7 libexpat1-dev libffi-dev libfile-stripnondeterminism-perl libfreetype6 libgcc-9-dev libgdbm-compat4 libgdbm6 libgfapi0 libgfchangelog0 libgfortran5 libgfrpc0 libgfxdr0 libgirepository-1.0-1 libglib2.0-0 libglib2.0-bin libglib2.0-data libglib2.0-dev libglib2.0-dev-bin libglusterfs0 libgmp-dev libgmpxx4ldbl libgnutls-dane0 libgnutls-openssl27 libgnutls28-dev libgnutlsxx28 libgomp1 libgpg-error-dev libgpgme-dev libgssrpc4 libhdb9-heimdal libicu-dev libicu66 libidn2-dev libip4tc2 libisl22 libitm1 libjbig-dev libjbig0 libjpeg-dev libjpeg-turbo8 libjpeg-turbo8-dev libjpeg8 libjpeg8-dev libjs-jquery libjs-jquery-ui libjson-c4 libjson-glib-1.0-0 libjson-glib-1.0-common libjson-perl libkadm5clnt-mit11 libkadm5clnt7-heimdal libkadm5srv-mit11 libkadm5srv8-heimdal libkafs0-heimdal libkdb5-9 libkdc2-heimdal libkmod2 libkrb5-dev liblapack3 libldap2-dev liblmdb-dev liblsan0 liblzma-dev libmaxminddb0 libmount-dev libmpc3 libmpfr6 libncurses-dev libncurses5-dev libnghttp2-14 libnl-genl-3-200 libopts25 libotp0-heimdal libp11-kit-dev libpam-systemd libpam0g-dev libparse-yapp-perl libpcap-dev libpcap0.8 libpcap0.8-dev libpcre16-3 libpcre2-16-0 libpcre2-32-0 libpcre2-dev libpcre2-posix2 libpcre3-dev libpcre32-3 libpcrecpp0v5 libperl5.30 libperlio-gzip-perl libpipeline1 libpng-dev libpng16-16 libproxy1v5 libpsl5 libpython3-dbg libpython3-dev libpython3.8-dbg libpython3.8-dev libquadmath0 libreadline-dev libreadline5 librtmp1 libselinux1-dev libsepol1-dev libsigsegv2 libsl0-heimdal libsoup2.4-1 libssh-4 libstdc++-9-dev libstemmer0d libsub-override-perl libsystemd-dev libtasn1-6-dev libtasn1-bin libtiff-dev libtiff5 libtiffxx5 libtirpc-common libtirpc3 libtool libtracker-control-2.0-0 libtracker-miner-2.0-0 libtracker-sparql-2.0-0 libtracker-sparql-2.0-dev libtsan0 libubsan1 libuchardet0 libunbound8 liburcu6 libuv1 libverto-libevent1 libverto1 libwebp6 libwrap0 libxml2 libxslt1.1 linux-libc-dev lmdb-utils locales lsb-release m4 make man-db mingw-w64 mingw-w64-common mingw-w64-i686-dev mingw-w64-x86-64-dev netbase nettle-dev ntp openssl patch perl perl-modules-5.30 pkg-config po-debconf psmisc python-matplotlib-data python3-certifi python3-dbg python3-dev python3-matplotlib python3-numpy python3-requests python3.8-dbg python3.8-dev quota rng-tools rpcbind rsync sgml-base sgml-data sudo systemd systemd-sysv tree ttf-bitstream-vera udev update-inetd uuid-dev wget xfslibs-dev xfsprogs xml-core xsltproc zlib1g-dev libboost-iostreams1.71.0 libboost-thread1.71.0 libcephfs2 libibverbs1 libldb2 liblmdb0 libnl-3-200 libnl-route-3-200 libpython3.8 librados2 librdmacm1 libtalloc2 libtdb1 libtevent0 libwbclient0 python3-chardet python3-cycler python3-dateutil python3-distutils python3-idna python3-jwt python3-kiwisolver python3-lib2to3 python3-ply python3-prettytable python3-talloc python3-urllib3 samba-common samba-libs ucf

RUN apt-get autoremove -y

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
