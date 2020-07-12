FROM golang:1.14.4-alpine3.12 as builder

RUN apk add --no-cache \
      make \
      git \
      # Hetzner Cloud CLI (https://github.com/hetznercloud/cli)
      && go get -u github.com/hetznercloud/cli/cmd/hcloud

FROM alpine:3.12

ARG HCLOUD_USER="hcloud"
ARG HCLOUD_HOME="/home/hcloud"
ARG PGID=""
ARG PUID=""

ENV HCLOUD_TOKEN="" \
    HCLOUD_CONTEXT="" \
    HCLOUD_CONFIG=""

RUN set +x \
    && apk add --no-cache \
      bash \
      tzdata \
      shadow \
      coreutils \
      ca-certificates \
      openssl \
      iputils \
      wget \
      curl \
    && groupadd -r -g "${PGID:-1000}" "${HCLOUD_USER}" \
    && useradd -r -m \
         --gid "${PGID:-1000}" \
         --uid "${PUID:-1000}" \
         -d "${HCLOUD_HOME}" \
            "${HCLOUD_USER}"

COPY --from=builder /go/bin/hcloud /usr/local/bin/hcloud

WORKDIR "${HCLOUD_HOME}"

USER "${HCLOUD_USER}"
