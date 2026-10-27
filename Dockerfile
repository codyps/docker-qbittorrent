FROM debian:unstable

ENV HOME="/config" \
  XDG_CONFIG_HOME="/config" \
  XDG_DATA_HOME="/config"

RUN apt-get update \
  && apt-get install -y qbittorrent-nox \
  && qbittorrent-nox --version \
  && rm -rf /var/lib/apt/lists/*

COPY ./qbt-start /usr/local/bin/qbt-start

VOLUME /config

EXPOSE 8080 6881 6881/udp

CMD ["qbt-start"]
