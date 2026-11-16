# Copyright 2026 Travis Grammer
# SPDX-License-Identifier: Apache-2.0
ARG ALPINE_GIT_TAG=latest
FROM alpine/git:${ALPINE_GIT_TAG}

RUN apk add --no-cache openssh-server && \
    mkdir -p /var/run/sshd && \
    adduser -D -s /usr/bin/git-shell git && \
    passwd -u git && \
    mkdir -p /home/git/.ssh && \
    chown git:git /home/git/.ssh && \
    chmod 700 /home/git/.ssh

COPY sshd_config /etc/ssh/sshd_config
COPY --chmod=755 entrypoint.sh /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
