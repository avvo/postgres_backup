FROM ubuntu:17.10
MAINTAINER Abi X Renhart "arenhart@avvo.com"

# from https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.3/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=96960ba3207756bb01e6892c978264e5362e117e

# install dependencies
RUN apt-get update \
&& apt-get install -y \
  curl \
  python \
  python-pip \
  postgresql \

# install supercronic
# (from https://github.com/aptible/supercronic/releases)
&& curl -fsSLO "$SUPERCRONIC_URL" \
&& echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
&& chmod +x "$SUPERCRONIC" \
&& mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
&& ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic \
&& mkdir -p /opt/backup \

# clean up dependencies
&& apt-get purge -y \
  curl \
&& apt-get autoremove -y \
&& rm -rf /var/lib/apt/lists/*

# Install s3cmd
RUN pip install s3cmd

# Install backup scripts
WORKDIR /opt/backup
ADD scripts /opt/backup/scripts
ADD entrypoint.sh /opt/backup/entrypoint.sh

# Start cron
ENTRYPOINT [ "/opt/backup/entrypoint.sh" ]
CMD [ "/usr/local/bin/supercronic", "/opt/backup/crontab" ]
