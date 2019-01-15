FROM centos:centos7
MAINTAINER Alec Saunders <alec.saunders@cotiviti.com>

ARG VERTICA_PACKAGE="vertica.rpm"

ENV LANG en_US.utf8
ENV TZ UTC

ADD packages/${VERTICA_PACKAGE} /tmp/

RUN yum -q -y update \
  && yum -q -y install \
    curl \
    gdb \
    mcelog \
    openssh \
    openssl \
    sysstat \
    which \
    m4 \
    sendmail \
    sendmail-cf

RUN  /usr/bin/curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.1/gosu' \
  &&/bin/chmod +x /usr/local/bin/gosu \
  && /usr/sbin/groupadd -r verticadba \
  && /usr/sbin/useradd -r -m -s /bin/bash -g verticadba dbadmin \
  && /usr/local/bin/gosu dbadmin mkdir /tmp/.python-eggs

RUN yum localinstall -q -y /tmp/${VERTICA_PACKAGE}

RUN /opt/vertica/sbin/install_vertica --license CE --accept-eula --hosts 127.0.0.1 \
  --dba-user-password-disabled --failure-threshold NONE --no-system-configuration \
  && /bin/rm -f /tmp/vertica*

ENV PYTHON_EGG_CACHE=/tmp/.python-eggs \
  VERTICADATA=/home/dbadmin/docker
VOLUME /home/dbadmin/docker
ENTRYPOINT ["/opt/vertica/bin/docker-entrypoint.sh"]
ADD ./docker-entrypoint.sh /opt/vertica/bin/

EXPOSE 5433
