FROM centos:centos7
MAINTAINER Alec Saunders <alec.saunders@cotiviti.com>

ARG VERTICA_PACKAGE="vertica.rpm"

ENV LANG en_US.utf8
ENV TZ UTC

ADD packages/${VERTICA_PACKAGE} /tmp/

RUN yum -q -y update \
  && yum -q -y install \
    iproute \
    openssl \
    gdb \
    mcelog \
    openssh \
    sysstat \
    which

RUN  /usr/sbin/groupadd -r verticadba \
  && /usr/sbin/useradd -r -m -s /bin/bash -g verticadba dbadmin \
  && mkdir /tmp/.python-eggs \
  && chown -R dbadmin:verticadba /tmp/.python-eggs

RUN yum localinstall -q -y /tmp/${VERTICA_PACKAGE}

RUN /opt/vertica/sbin/install_vertica --license CE --accept-eula --hosts 127.0.0.1 \
  --dba-user-password-disabled --failure-threshold NONE --no-system-configuration \
  && /bin/rm -f /tmp/vertica*

ENV PYTHON_EGG_CACHE=/tmp/.python-eggs \
  VERTICADATA=/home/dbadmin/docker
VOLUME /home/dbadmin/docker

ENTRYPOINT ["/opt/vertica/bin/create_db.sh"]
ADD ./create_db.sh /opt/vertica/bin/

EXPOSE 5433
