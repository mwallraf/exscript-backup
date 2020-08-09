FROM alpine:3.12.0

ARG TZ='Europe/Brussels'

ARG SCRIPTDIR='/opt/exscript-backup'

ENV TZ ${TZ}

RUN apk update

RUN apk add --no-cache bash busybox-extras openssh-client nmap python3 python3-dev libc-dev py3-pip py3-virtualenv py3-yaml tzdata gcc py3-cffi py3-bcrypt py3-cryptography py3-pynacl py3-netaddr

# create an alias for python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install exscript
RUN pip install exscript

# Add old SSH encryptions
RUN echo "KexAlgorithms +diffie-hellman-group1-sha1,diffie-hellman-group14-sha1" >> /etc/ssh/ssh_config

# Create the network-discovery folder
RUN mkdir -p ${SCRIPTDIR}
RUN chmod -R 755 ${SCRIPTDIR}

# Add files
ADD . ${SCRIPTDIR}
ADD functions/entrypoint.sh /entrypoint.sh

RUN chmod -R 755 /entrypoint.sh
RUN chmod -R 755 ${SCRIPTDIR}/exscript-backup.sh

ENTRYPOINT /entrypoint.sh
