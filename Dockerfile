# Copyright 2026 Travis Grammer
# SPDX-License-Identifier: Apache-2.0
ARG ALPINE_GIT_TAG=v2.54.1
FROM alpine/git:${ALPINE_GIT_TAG}

ARG VERSION=dev
ARG REVISION=unknown

LABEL org.opencontainers.image.title="docker-git-remote" \
      org.opencontainers.image.description="Minimal, headless SSH git remote container" \
      org.opencontainers.image.source="https://github.com/travis-g/git" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${REVISION}"

RUN apk add --no-cache openssh-server && \
    mkdir -p /var/run/sshd && \
    adduser -D -s /usr/local/bin/git-shell-wrapper git && \
    passwd -u git && \
    mkdir -p /home/git/.ssh && \
    chown git:git /home/git/.ssh && \
    chmod 700 /home/git/.ssh && \
    echo /usr/local/bin/git-shell-wrapper >> /etc/shells

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /entrypoint.sh
COPY git-shell-wrapper /usr/local/bin/git-shell-wrapper
RUN chmod 755 /entrypoint.sh /usr/local/bin/git-shell-wrapper

ENV GIT_AUTO_CREATE_MIN_DEPTH=2 \
    GIT_AUTO_CREATE_MAX_DEPTH=2

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
