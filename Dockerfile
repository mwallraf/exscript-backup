FROM alpine:3.12.0

ARG TZ='Europe/Brussels'

ARG SCRIPTDIR='/opt/exscript-backup'

ENV TZ ${TZ}

RUN apk update

RUN apk add --no-cache bash busybox-extras openssh-client nmap python3 python3-dev libc-dev py3-pip py3-virtualenv py3-yaml tzdata gcc py3-cffi py3-bcrypt py3-cryptography py3-pynacl py3-netaddr procps

# create an alias for python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Add old SSH encryptions
RUN echo "KexAlgorithms +diffie-hellman-group1-sha1,diffie-hellman-group14-sha1" >> /etc/ssh/ssh_config
RUN echo "HostKeyAlgorithms=+ssh-dss" >> /etc/ssh/ssh_config

# Create the network-discovery folder
RUN mkdir -p ${SCRIPTDIR}
RUN chmod -R 755 ${SCRIPTDIR}

# Add files
ADD . ${SCRIPTDIR}
ADD functions/entrypoint.sh /entrypoint.sh

RUN chmod -R 755 /entrypoint.sh
RUN chmod -R 755 ${SCRIPTDIR}/exscript-backup.sh

WORKDIR ${SCRIPTDIR}

# Install python requirements
RUN pip install -r functions/requirements.txt

# patch the Exscript ssh2.py file to fix cisco bug (see readme file)
ADD functions/patches/ssh2.py /usr/lib/python3.8/site-packages/Exscript/protocols/ssh2.py

ENTRYPOINT /entrypoint.sh
