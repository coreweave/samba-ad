# coreweave/samba-ad

This Docker image, based on Debian, uses Samba and Winbind to join a defined domain. Samba creates a file share using a user group on a designated domain for access.

The container entry point `/entrypoint.sh` expects the following environment variables: 

- `DCIP`: The IP of the primary domain controller located in your namespace
- `DNSDOMAIN`: The fully qualified search realm of your domain
- `DOMAINNAME`: The name of your domain (not fully qualified)
- `SHARE*`: Names of the Shared Filesystem PVC to be mounted as a file share
- `GROUPNAME`: Group granted ownership access of the shared PVC
- `AD_USERNAME`: User account in your domain with domain join permissions
- `AD_PASSWORD`: Password of user account in your domain with domain join permissions

Services `smbd` `nmbd` and `winbindd` are controlled by `supervisord`.
