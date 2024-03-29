#! /bin/bash

#service smbd stop
#service nmbd stop
#service winbind stop

rm /etc/samba/smb.conf
rm /usr/local/samba/share/setup/krb5.conf

cat > /etc/hosts << EOL
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
fe00::0 ip6-mcastprefix
fe00::1 ip6-allnodes
fe00::2 ip6-allrouters
${DCIP} ${DNSDOMAIN}
127.0.0.1 $(cat /proc/sys/kernel/hostname).${DNSDOMAIN} $(cat /proc/sys/kernel/hostname)
EOL

sed -i '/^passwd:/ s/$/ winbind/' /etc/nsswitch.conf
sed -i '/^group:/ s/$/ winbind/' /etc/nsswitch.conf
sed -i '/^passwd:/ s/$/ winbind/' /usr/share/libc-bin/nsswitch.conf
sed -i '/^group:/ s/$/ winbind/' /usr/share/libc-bin/nsswitch.conf

cat > /usr/local/samba/share/setup/krb5.conf << EOL
[libdefaults]
    default_realm = ${DNSDOMAIN}
    dns_lookup_realm = false
    dns_lookup_kdc = true
EOL

cat > /etc/samba/user.map << EOL
!root = ${DOMAINNAME}\Administrator ${DOMAINNAME}\administrator Administrator administrator
EOL

if [ -w /usr/local/samba/etc/smb.conf ] || [ ! -f /usr/local/samba/etc/smb.conf ]
then
cat > /usr/local/samba/etc/smb.conf << EOL
[global]
    workgroup = ${DOMAINNAME}
    security = ADS
    realm = ${DNSDOMAIN}

    dedicated keytab file = /etc/krb5.keytab
    kerberos method = secrets and keytab
    server string = Data %h

    winbind use default domain = yes
    winbind expand groups = 4
    winbind nss info = rfc2307
    winbind refresh tickets = Yes
    winbind offline logon = yes
    winbind normalize names = no
    winbind enum users = yes
    winbind enum groups = yes

    ## map ids outside of domain to tdb files.
    idmap config *:backend = tdb
    idmap config *:range = 3000-9999
    ## map ids from the domain  the ranges may not overlap !
    idmap config ${DOMAINNAME} : backend = rid
    idmap config ${DOMAINNAME} : range = 10000-999999
    template shell = /bin/bash
    template homedir = /home/${DOMAINNAME}/%U

    domain master = no
    local master = no
    preferred master = no
    os level = 20
    map to guest = bad user
    host msdfs = yes

    # user Administrator workaround, without it you are unable to set privileges
    username map = /etc/samba/user.map

    # For ACL support on domain member
    vfs objects = acl_xattr
    map acl inherit = Yes
    store dos attributes = Yes
    acl_xattr:ignore system acls = no
    acl_xattr:security_acl_name = user.NTACL

    # Share Setting Globally
    unix extensions = yes
    reset on zero vc = yes
    veto files = /.bash_logout/.bash_profile/.bash_history/.bashrc/
    hide unreadable = no

    # disable printing completely
    load printers = no
    printing = bsd
    printcap name = /dev/null
    disable spoolss = yes

    # Security
    client ipc min protocol = SMB2_10
    client min protocol = SMB2_10
    server min protocol = SMB2_10
    smb encrypt = auto
    log level = ${LOG_LEVEL:="1"}
    log file = /dev/stdout

    #SMB Multichannel
    server multi channel support = yes
    aio read size = 1
    aio write size = 1
    
    #Tuning
    min receivefile size = 16384
    use sendfile = true
EOL
fi

if [ -w /usr/local/samba/etc/smb.conf ] || [ ! -f /usr/local/samba/etc/smb.conf ]
then
for var in ${!SHARE@};
do
echo "" >> /usr/local/samba/etc/smb.conf
echo "[${!var}]" >> /usr/local/samba/etc/smb.conf
echo "   path = /share/samba/${!var}" >> /usr/local/samba/etc/smb.conf
echo "   read only = no"  >> /usr/local/samba/etc/smb.conf
echo "   guest ok = no" >> /usr/local/samba/etc/smb.conf
done

echo "" >> /usr/local/samba/etc/smb.conf
fi

net ads join -U"${AD_USERNAME}"%"${AD_PASSWORD}" || exit 1

smbd -D
nmbd -D
winbindd -D

until getent passwd "${DOMAINNAME}\\${AD_USERNAME}"; do sleep 1; done

net ads dns register -U"${AD_USERNAME}"%"${AD_PASSWORD}" || exit 1

for var in ${!SHARE@};
do
chown "${DOMAINNAME}\\Domain Admins":"${DOMAINNAME}\\Domain Admins" /share/samba/${!var}
chmod 0770 /share/samba/${!var};
done

net rpc rights grant "${DOMAINNAME}\\Domain Admins" SeDiskOperatorPrivilege   -U"${AD_USERNAME}"%"${AD_PASSWORD}"

pkill -INT smbd
pkill -INT nmbd
pkill -INT winbindd

exec "$@"
