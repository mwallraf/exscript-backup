# exscript-backup
Backup script for network devices based on exscript


docker build --tag mwallraf/exscript-backup:latest .

docker run --detach --name exscript-backup mwallraf/exscript-backup:latest


exscript --verbose=0 --protocol-verbose=0 --ssh-auto-verify --logdir=/tmp  /opt/exscript-backup/etc/test.exscript ssh://25.0.32.1

