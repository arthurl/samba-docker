
FROM arthurl/debian:v2.0

MAINTAINER Arthur Lee <me@arthur.li>

# gettext for envsubst
RUN apt-get install -yq samba gettext

EXPOSE 137/udp 138/udp 139 445

ADD smb.conf /etc/samba/smb.conf
ADD share.tmpl /share.tmpl
ADD setup.sh /setup.sh

ENTRYPOINT ["/setup.sh"]
