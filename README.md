# exscript-backup
Backup script for network devices based on exscript


docker build --tag mwallraf/exscript-backup:latest .

docker run --detach --name exscript-backup mwallraf/exscript-backup:latest

- /var/log/exscript-backup:/opt/exscript-backup/log
- /opt/SCRIPTS/exscript-backup/archive:/opt/exscript-backup/archive
- /opt/SCRIPTS/exscript-backup/configs:/opt/exscript-backup/configs
- /opt/SCRIPTS/exscript-backup/etc/templates:/opt/exscript-backup/etc/templates
- /etc/obe/auth:/opt/exscript-backup/etc/auth
- /opt/SCRIPTS/exscript-backup/hosts:/opt/exscript-backup/hosts
- /opt/SCRIPTS/exscript-backup/lib:/opt/exscript-backup/lib


exscript --verbose=0 --protocol-verbose=0 --ssh-auto-verify --logdir=/tmp  /opt/exscript-backup/etc/test.exscript ssh://25.0.32.1



=> install docker, add host files to input folder and run:

exscript-backup.sh backup



CAVEAT
---------

* Sessions see to hang when encryption formats are not supported, see the addtion of older SSH encryption types in Dockerfile.