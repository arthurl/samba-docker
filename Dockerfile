FROM debian:jessie

MAINTAINER Arthur Lee <me@arthur.li>

ENV DEBIAN_FRONTEND noninteractive

# Not essential, but wise to set the lang
# Note: Users with other languages should set this in their derivative image
RUN apt-get update && \
    apt-get -y install locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && dpkg-reconfigure locales
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# gettext for envsubst
RUN apt-get install -yq samba gettext

EXPOSE 137/udp 138/udp 139 445

ADD smb.conf /etc/samba/smb.conf
ADD share.tmpl /share.tmpl
ADD setup.sh /setup.sh

ENTRYPOINT ["/setup.sh"]
